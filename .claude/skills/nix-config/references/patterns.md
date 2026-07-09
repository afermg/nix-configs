# The five management patterns

Full code, plus the per-pattern gotchas this user has hit. Patterns 1-4 are
the workhorses; pattern 5 is rarely the right answer but covered for
completeness.

## Pattern 1: Nix-baked file (`home.file` + `builtins.readFile` or `text`)

```nix
# modules/shared/files.nix
{ config, ... }:
{
  ".mbsyncrc" = {
    text = builtins.readFile ../shared/config/email/mbsyncrc;
  };
}
```

Or for JSON:

```nix
# modules/shared/config/email/rbw.nix
{ pkgs, ... }:
{
  xdg.configFile."rbw/config.json" = {
    text = builtins.toJSON {
      lock_timeout = 28800;
      pinentry = "${pkgs.pinentry-curses}/bin/pinentry-tty";
    };
  };
}
```

**Mechanics:** at build time, nix evaluates the text/JSON, writes it to a
file in `/nix/store`, and points `~/.mbsyncrc` (or `~/.config/rbw/config.json`)
at it. The file is mode 0444 forever.

**When to use:** static-ish config you author entirely yourself, no other tool
writes to it, the app doesn't enforce strict perms, you're OK rebuilding to
change the file.

**Gotchas:**

- `onChange = "chmod 600 $HOME/.foorc"` will fail with
  `Read-only file system` because the symlink target is in `/nix/store`. If
  the app needs strict perms, switch to Pattern 2.
- Reference package paths via `${pkgs.<pkg>}/bin/...`, never hardcoded
  `/nix/store/<hash>-<pkg>/bin/...`. The hash changes on every package update;
  hardcoded paths break silently.
- If multiple files share a category, group them in
  `modules/shared/config/<cat>/` and import via a standalone `.nix` module —
  don't pile everything into `files.nix`.

## Pattern 2: Dedicated home-manager module

```nix
# homes/amunoz/home.nix
programs.msmtp.enable = true;
accounts.email = {
  maildirBasePath = ".mail";
  accounts = {
    quasimorphic = {
      primary = true;
      realName = "Alán F. Muñoz";
      address = "alan@quasimorphic.com";
      userName = "alan@quasimorphic.com";
      passwordCommand = [ "rbw" "get" "'Quasimorphic Email'" ];
      smtp = {
        host = "witcher.mxrouting.net";
        port = 465;
        tls.useStartTls = false;
      };
      msmtp.enable = true;
    };
    broad = {
      realName = "Alán F. Muñoz";
      address = "amunozgo@broadinstitute.org";
      userName = "amunozgo@broadinstitute.org";
      passwordCommand = [ "rbw" "get" "'Broad Email App Password'" ];
      smtp = {
        host = "smtp.gmail.com";
        port = 465;
        tls.useStartTls = false;
      };
      msmtp.enable = true;
    };
  };
};
```

**Mechanics:** the home-manager module renders the rc file with correct
syntax, places it at the canonical XDG path (e.g. `~/.config/msmtp/config`),
and handles permissions/format quirks. You configure declaratively; the
module renders.

**When to use:** any app that ships a home-manager module AND has quirky
requirements (perms, path conventions, format complexity).

**Gotchas (specific instances we've hit):**

- **`accounts.email.passwordCommand` quoting** — rendered with plain
  `toString`, no shell escaping. Multi-word args (rbw entry names with spaces)
  must embed their own single quotes:
  `[ "rbw" "get" "'Broad Email App Password'" ]`. The outer quotes survive
  the toString round-trip; the inner shell parses them correctly. Without
  them, rbw receives 4 args ("Broad", "Email", "App", "Password") and fails
  silently (msmtp surfaces it as opaque auth error).

- **msmtp 0600 check is conditional** — only fires when there's a literal
  `password = ...` line in the rc file. With `passwordeval` (which is what
  `passwordCommand` produces), the file has no plaintext secret, msmtp
  accepts mode 0444, and the `/nix/store` symlink works. Don't preemptively
  panic about perms on this module.

- **`realName` is required even when it feels optional** — eval fails with
  `option 'realName' has no value defined` if you omit it. Same `address` /
  `userName` for any enabled account.

- **Don't try to mix Pattern 1 and Pattern 2 for the same app** — you can't
  have both `home.file.".msmtprc"` and `programs.msmtp.enable = true`. Delete
  the old `home.file` entry AND remove the stale dotfile (`rm ~/.msmtprc`)
  before activating the home-manager module, or activation will refuse to
  overwrite an unknown file.

## Pattern 3: Out-of-store symlink (`mkOutOfStoreSymlink`)

```nix
# modules/shared/config/claude/claude.nix
{ config, ... }:
{
  # ~/.claude/settings.json is an out-of-store symlink resolving to the repo
  # file (two-hop: `ls -l` shows a /nix/store/...-home-manager-files path, which
  # is itself a symlink to the repo path — `readlink -f` resolves through to the
  # repo file). The repo path stays the single source of truth (declarative,
  # version-controlled), and Claude can edit it directly via /permissions,
  # /plugin add, etc. — those edits land on the tracked file and show up in
  # `git status` for review/commit.
  home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/claude/settings.json";
}
```

Same trick used for emacs:

```nix
# modules/shared/files.nix
".emacs.d/init.el" = {
  source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/emacs/init.el";
};
```

**Mechanics:** home-manager registers the entry in the generation's
`home-manager-files` store dir, so `~/.claude/settings.json` first-hops into
`/nix/store/<hash>-home-manager-files/.claude/settings.json` — but that store
entry is itself a symlink to the absolute repo path you gave `mkOutOfStoreSymlink`,
so `readlink -f` resolves all the way to the repo file. Don't be fooled by
`ls -l` showing a `/nix/store` target; the tell for out-of-store vs nix-baked
(Pattern 1) is the *final* resolved target: a live writable repo file here vs a
read-only content *copy* in the store for Pattern 1. `config.home.homeDirectory`
makes the path host-portable. Edits to the repo file land on disk immediately;
no rebuild needed.

**When to use:** the file changes more often than you want to rebuild for,
OR another tool writes to it and you want the writes preserved across
rebuilds.

**Gotchas:**

- **Target file must be `git add`'d.** Flakes ignore untracked files. New
  symlinks fail eval with `path '...' does not exist` until the target is
  tracked. `git add -N <file>` (intent-to-add) is enough to make eval succeed.

- **The repo path is the source of truth, not the nix module.** If you
  later want to add a new declarative key to a Pattern-3 file, you can't —
  the symlink points at the actual file content. You'd have to convert back
  to Pattern 1 (which loses the imperative-edit benefit) or merge manually.
  Choose this pattern only when you accept that nix is the *seed*, not the
  authority.

- **Diff noise from external tools** — when Claude rewrites
  `settings.json`, key ordering and indentation may drift from what you'd
  hand-write. `git diff` will show the formatting churn. Either accept it,
  reformat with `jq . | sponge`, or pre-commit-hook a canonicalizer.

- **Re-seeding** — to discard imperative edits and reset to whatever's in
  the repo, just `git restore <file>` and the symlink keeps pointing at the
  restored content.

## Pattern 4: Unmanaged (the courage to leave it alone)

This isn't really a "pattern" — it's the discipline NOT to write a `.nix`
module for things the app should own.

**Examples this repo correctly leaves alone:**
- `~/.mail/` (mu4e maildirs — mbsync writes, app reads)
- `~/.config/elfeed/db/` (elfeed RSS database)
- `~/.local/share/atuin/` (atuin shell-history db, encrypted)
- `~/.claude/projects/<...>/<sid>.jsonl` (claude transcripts — even though
  `~/.claude/settings.json` IS managed, the per-session transcripts are
  pure runtime state)

**Tempting bad ideas:**

- "Let me seed an empty `~/.claude/projects/` so nix knows about it." —
  No. Claude creates it on first use; nix doesn't need to know.
- "Let me write a `.nix` module that backs up `~/.local/share/atuin/`." —
  Backups are a separate concern from configuration management. Use
  borg/restic/syncthing/whatever; don't conflate.
- "The mbsync maildir paths are in nix; surely the directories should be
  too." — No. The path is a *configuration* (managed); the directory
  contents are *state* (unmanaged).

**The test:** if I `rm -rf` this file/directory, would the app correctly
recreate it on next launch? If yes, it's runtime state — leave it alone.
If no (because it contains config), it should be in Pattern 1, 2, or 3.

## Pattern 5: `home.activation` seed (rarely the right choice)

```nix
home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  dest="$HOME/.claude/settings.json"
  if [ -L "$dest" ] || [ ! -e "$dest" ]; then
    run rm -f "$dest"
    run install -D -m 644 ${seed} "$dest"
  fi
'';
```

**Mechanics:** runs a shell snippet during home-manager activation. The
snippet copies a file into place ONCE (guarded by `[ -L ] || [ ! -e ]`),
then leaves it alone on subsequent rebuilds. The user (or app) can then
imperatively edit the file without losing changes on every switch.

**When this is appropriate:**
- You genuinely want "set initial state, then never touch again" — and
  Pattern 3 (out-of-store symlink) is wrong because the source of truth
  should NOT be in the repo.
- The file lives somewhere you can't symlink (e.g., the app does
  `realpath` and rejects symlinks).

**When this is wrong (almost always — prefer Pattern 3):**
- "I want claude to edit `settings.json` and survive rebuilds." → Pattern 3.
  The symlink approach also lets the repo file evolve.
- "I want declarative defaults plus user overrides." → Don't conflate the
  two; commit to Pattern 1 (declarative wins, no overrides) or Pattern 3
  (user wins, repo seeds).

The reason to mention this pattern is that it looks superficially
appealing — "seed once, then leave alone" — and we tried it for
`~/.claude/settings.json` before realizing Pattern 3 is strictly better.
The seed pattern's downside: declarative changes to `seed` never propagate
to existing installs, only to fresh ones. You silently drift.

## Quick selection cheatsheet

| Question | Answer → Pattern |
|---|---|
| Does another tool write to this file? | Yes → 3 (or 4 if you don't want to track) |
| Does the app enforce strict perms / weird format? | Yes → 2 |
| Will I edit this file >1×/month? | Yes → 3 |
| None of the above? | 1 |
| Is this runtime state? | 4 |
| Do I want "seed once, never touch again"? | 5 (but reconsider — usually 3) |
