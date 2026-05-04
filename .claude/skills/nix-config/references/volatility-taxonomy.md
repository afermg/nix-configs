# Volatility taxonomy

The decision of where a config should live is dominated by **how often it
changes** and **who writes to it**. This file walks the four tiers with a real
example per tier from this repo, plus the warning signs that a config is in
the wrong tier.

## Tier 0 — Never changes (or changes only when the repo structure does)

**Examples in this repo:** `flake.nix`, the per-host module entry points
(`machines/moby/default.nix`), the directory layout itself, `overlays/`.

**Pattern:** authored as nix code directly. Not a "config file" at all —
these define the topology of the system.

**Warning signs you've put something here that should be in another tier:**
- You're rebuilding the whole system to test a one-line change → likely
  Tier 2 or 3 territory.
- You're editing a `text = ''…''` block in a `.nix` module repeatedly to tweak
  prose / formatting → consider `builtins.readFile` of a real text file.

## Tier 1 — Rare changes (months), the app has quirky requirements

**Examples in this repo:** msmtp accounts, fish plugin list, git config, gpg
agent config, ssh client config.

**Pattern:** dedicated home-manager module — `programs.<x>.enable = true` plus
the module's option tree. Why? Because these apps care about specific things:
- msmtp wants 0600 when there's a literal password
- ssh wants 0600 on the rc file, 0700 on `~/.ssh`
- gpg wants 0700 on `~/.gnupg`
- fish wants its config under XDG with a particular layout

The home-manager module knows the right path and writes the file with the
right structure. You configure via nix attrs (`accounts.email.accounts.<n>`),
not by hand-rolling the rc-file syntax.

**Warning signs you've put something here that belongs elsewhere:**
- You're editing the `accounts.email.accounts.<n>.<field>` value weekly →
  consider whether the *content* is more volatile than the *structure*; you
  might want a per-host overlay or env-var injection.
- The home-manager module doesn't exist for this app → fall back to Tier 2
  (nix-baked text file) and accept the perm-handling work.

## Tier 2 — Rare-to-moderate changes, you author the whole thing in nix

**Examples in this repo:** `~/.mbsyncrc` (raw `home.file` with
`builtins.readFile ../shared/config/email/mbsyncrc`), the rbw config JSON
(via `xdg.configFile.rbw/config.json` + `builtins.toJSON`).

**Pattern:** `home.file."path".text = builtins.readFile <repo-file>` for
non-XDG dotfiles, `xdg.configFile."app/config".text = builtins.toJSON {...}`
for XDG-aware apps that take JSON.

You commit the source content to the repo. On rebuild, nix copies it into
`/nix/store` (mode 0444) and symlinks `~/.foorc` to it.

**Warning signs you've put something here that should move to Tier 3:**
- The `onChange` hook needs to `chmod` the file → Tier 1 (home-manager module)
  or some other approach. `/nix/store` is read-only; `chmod` will fail.
- You're rebuilding daily to tweak the file → move to Tier 3 (out-of-store
  symlink) so edits don't need a rebuild.
- Another tool wants to write to the file → must be Tier 3 (or unmanaged).

## Tier 3 — Frequent changes (days–weeks), you and/or another tool both write

**Examples in this repo:**
- `~/.emacs.d/init.el` symlinked to
  `modules/shared/config/emacs/init.el` (`mkOutOfStoreSymlink` in
  `modules/shared/files.nix`). I edit this constantly; rebuilding to test
  init.el changes would be untenable.
- `~/.claude/settings.json` symlinked to
  `modules/shared/config/claude/settings.json`. Both you (declaratively) and
  Claude itself (via `/permissions add ...`) write to it; the symlink lets
  Claude's writes flow back to the repo file so they survive rebuilds.

**Pattern:** `home.file."path".source = config.lib.file.mkOutOfStoreSymlink
"<absolute-repo-path>"`. The symlink target is your live repo file, NOT
`/nix/store`. Edits in your editor or by external tools land on the tracked
file directly and show up in `git status` for review.

**Two requirements to make this work:**
1. The repo file must be `git add`'d. Flakes only see git-tracked files; an
   untracked target makes flake eval fail with `path '...' does not exist`.
2. The user has to know that this file is the source of truth — adding a new
   value to the underlying nix module won't override their imperative edit.
   Comment the file accordingly when you set up the symlink.

**Warning signs:**
- Other people / scripts also write to this file but you don't want their
  changes tracked → consider Tier 4 (unmanaged) instead, or tier 3 with a
  `.gitignore` entry on the symlink target (rare).
- You want a "default" baked in but the user can override → consider the
  rare `home.activation` seed pattern (see `patterns.md`); usually a worse
  choice than `mkOutOfStoreSymlink` but legitimate when you want write-once.

## Tier 4 — Runtime state, owned by the app

**Examples in this repo (DO NOT manage in nix):**
- mu4e's maildir (`~/.mail/`)
- mbsync's per-account state (`~/.mbsync/`)
- elfeed database (`~/.config/elfeed/db/`)
- claude's conversation transcripts (`~/.claude/projects/...*.jsonl`)
- claude's per-PID session files (`~/.claude/sessions/<pid>.json`)
- fish history (`~/.local/share/fish/fish_history`)
- atuin's encrypted db (`~/.local/share/atuin/`)
- shell-history-style state in general

**Pattern:** none. Don't reference these files from any `.nix` module. Let
the app create and own them.

**Why this matters:** putting these under nix either:
1. Puts them in `/nix/store` (read-only, app crashes when it tries to write).
2. Forces you into `home.activation` seed logic with awkward "create if not
   exists" guards that quickly drift from app expectations.
3. Wipes the user's actual data on rebuild (worst case).

The right answer for runtime state is to leave it alone. If you need to
reset it (corrupt elfeed db, want a fresh fish history), do that imperatively
once; don't bake it into the rebuild.

## Edge cases that bend the rules

A handful of configs look like one tier but actually want another:

- **Nix module that *reads* from a Tier 4 file** — fine. Example:
  `mu4e-mu-version` is auto-derived from the running `mu` binary at
  `home-manager` build time (see `config.org`'s mu4e block). The module reads
  state, doesn't manage it.
- **Tier 3 file that another machine reads via syncthing** — pin the symlink
  target to a syncthing-watched path, leave the syncing to syncthing. Don't
  try to express "sync this between machines" in nix.
- **Secrets** — never go in any of the above tiers in cleartext. Use agenix
  (`age.secrets.<name>.file = ./secrets/<name>.age;`); the secret lands at a
  configurable path with `0600 root:user` automatically. The nix file
  references the encrypted blob; the rebuild decrypts on activation.
