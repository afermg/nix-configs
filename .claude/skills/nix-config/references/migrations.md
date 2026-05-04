# Migrations between patterns

Recipes for moving a config from one pattern to another, including the
cleanup steps that the rebuild won't do for you.

The non-obvious part of every migration is **the leftover artifact**. When
you switch a config from Pattern 1 to Pattern 2, the old `~/.foorc` symlink
is still there pointing at the old `/nix/store` path; activation either
refuses to overwrite it or silently leaves both paths in place. Each recipe
below tells you what to clean up by hand.

## Pattern 1 → Pattern 2: nix-baked → home-manager module

**When:** the app enforces strict perms (msmtp 0600, ssh 0600), you can't
satisfy them via Pattern 1's `/nix/store` symlink, OR there's a proper
home-manager module that handles per-account quirks better than your raw
file.

**Worked example: msmtp** (the actual migration we did in this repo).

Before:

```nix
# modules/shared/files.nix
".msmtprc" = {
  text = builtins.readFile ../shared/config/email/msmtprc;
  onChange = "chmod 600 $HOME/.msmtprc";    # ← FAILS: read-only target
};
```

Plus a hand-authored `modules/shared/config/email/msmtprc` text file.

After:

```nix
# modules/shared/files.nix     (msmtprc entry removed entirely)
".mbsyncrc" = {
  text = builtins.readFile ../shared/config/email/mbsyncrc;
};
# (no .msmtprc entry — handled by programs.msmtp now)

# homes/amunoz/home.nix
programs.msmtp.enable = true;
accounts.email = {
  maildirBasePath = ".mail";
  accounts = {
    quasimorphic = { /* ... see patterns.md ... */ };
    broad        = { /* ... */ };
  };
};
```

Migration steps in order:

1. **Translate the rc file fields into module options.** `port 465` → `smtp.port = 465;`,
   `tls_starttls off` → `smtp.tls.useStartTls = false;`, `passwordeval "rbw get '<n>'"`
   → `passwordCommand = [ "rbw" "get" "'<n>'" ];` (note the embedded single
   quotes — see `patterns.md` for why). `account default : <n>` → set
   `primary = true;` on that account.
2. **Remove the `home.file` entry** from `modules/shared/files.nix`.
3. **Delete the source text file** if no other module references it
   (`modules/shared/config/email/msmtprc` in this case).
4. **`nixos-rebuild build`** to validate.
5. **`rm` the stale dotfile** at the OLD path:
   ```bash
   rm -f ~/.msmtprc
   ```
   This is the step that's easy to forget. Without it, activation may
   either refuse to overwrite `~/.msmtprc` (it doesn't recognize an
   unmanaged file) or, in our actual case, leave a broken symlink to a
   no-longer-existent `/nix/store` path.
6. **`sudo nixos-rebuild switch`** to activate. The new generation creates
   `~/.config/msmtp/config` (the canonical XDG path the home-manager module
   uses).
7. **Verify**: `ls -la ~/.config/msmtp/config` should show a symlink into
   the latest home-manager generation; `head ~/.config/msmtp/config`
   should show the rendered accounts.
8. **Smoke test**: `msmtp -a <account> --serverinfo` should print the SMTP
   banner.

**Trap unique to the password-command rendering** — if your rbw entry name
contains spaces and you forget the embedded quotes in the list element, the
build succeeds, the file looks fine, but rbw fails at fire time because
it receives 4 args instead of 1. The bug is visible only at runtime. After
migration, always smoke-test `--serverinfo` BEFORE relying on the migration
to send mail.

## Pattern 1 → Pattern 3: nix-baked → out-of-store symlink

**When:** the file changes often enough that "edit, rebuild, test" is
slowing you down.

**Worked example: claude `settings.json`** (we did exactly this).

Before:

```nix
# modules/shared/config/claude/claude.nix
home.file.".claude/settings.json".source = pkgs.writers.writeJSON
  "claude-settings.json" {
    permissions.defaultMode = "bypassPermissions";
    enabledPlugins = { /* ... */ };
    /* ... */
  };
```

After:

```nix
# modules/shared/config/claude/claude.nix
{ config, ... }:
{
  home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/claude/settings.json";
}
```

Plus `modules/shared/config/claude/settings.json` as a tracked text file.

Migration steps:

1. **Materialize the current rendered content into a real file.** The
   simplest way: read the existing symlink target
   (`cat ~/.claude/settings.json` while the OLD generation is still
   active) and save the contents to the new repo path. This way you don't
   lose any imperative edits the user/tool already made.
2. **Edit the `.nix` module** to swap `.source = pkgs.writers.writeJSON ...`
   for `.source = config.lib.file.mkOutOfStoreSymlink "<absolute-path>"`.
   Use `${config.home.homeDirectory}` for portability across hosts.
3. **`git add`** the new tracked file. (Without this, eval fails:
   `path '...' does not exist`.)
4. **`nixos-rebuild build`** to validate.
5. **`sudo nixos-rebuild switch`** to activate. The symlink at
   `~/.claude/settings.json` now points back at the repo file.
6. **Verify**: `readlink -f ~/.claude/settings.json` should resolve to the
   repo path through the home-manager-files indirection.

**No `rm` step needed** — home-manager replaces the symlink in place. But
do verify with `readlink -f` because if the user/tool had imperatively
deleted `~/.claude/settings.json` and recreated it as a regular file
(breaking the home-manager invariant), activation might leave that file
alone instead of replacing it. In that case, `rm ~/.claude/settings.json`
and rebuild.

## Pattern 5 → Pattern 3: activation seed → out-of-store symlink

**When:** you're regretting a `home.activation` seed because:
- declarative changes to the seed never propagate to existing installs
- you can't tell from the file whether the user has edited it
- another tool's writes to the file aren't surviving rebuilds the way you
  expected (they ARE surviving, but if you ever do `rm` and rebuild, you
  re-seed the old defaults, losing the imperative state)

**Worked example: claude `settings.json`** (we did this too — first did
Pattern 5, then realized Pattern 3 was strictly better).

Before:

```nix
home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  dest="$HOME/.claude/settings.json"
  if [ -L "$dest" ] || [ ! -e "$dest" ]; then
    run rm -f "$dest"
    run install -D -m 644 ${seed} "$dest"
  fi
'';
```

After: the Pattern-3 form shown in the previous section.

Migration steps:

1. **Materialize the live content** — same as Pattern 1 → Pattern 3, step 1.
   Read `~/.claude/settings.json` (which is currently a regular file, not a
   symlink, because the activation seeded it) and save to the repo path.
2. **Replace the `home.activation` block** with the `mkOutOfStoreSymlink`
   form.
3. **`rm ~/.claude/settings.json`** — important. The activation left a real
   file there; without removing it, home-manager won't replace a regular
   file with a symlink (it errors out to avoid clobbering user data).
4. **`git add`** the new repo file.
5. **`nixos-rebuild switch`**. Activation creates the symlink.
6. **Verify** with `readlink -f`.

## Pattern 2 → Pattern 1: home-manager module → nix-baked

**When:** the home-manager module is over-prescriptive for your needs and
you'd rather author the rc file directly. Rare; usually goes the other way.

Migration steps:

1. **Render the current module output** to capture exactly what the module
   was producing: `cat ~/.config/<app>/config` (or wherever the module
   writes). Save that text to a tracked source file in the repo.
2. **Remove the `programs.<app>.enable = true;`** and the entire option
   tree. Be ruthless — leftover accounts/options will silently still
   render even if the master enable is gone (some modules generate at
   evaluation time regardless of `enable`).
3. **Add a `home.file."<path>".text = builtins.readFile ../path/to/source;`**
   entry for the file.
4. **`rm`** the old XDG file if the new path is different (e.g., moving from
   `~/.config/<app>/config` to `~/.<apprc>`).
5. Build, switch, verify, smoke-test.

The risk in this direction is missing perm/format quirks the module was
handling for you. If you migrate this way and the app starts complaining,
the module was earning its keep — go back to Pattern 2.

## Pattern 4 → anything: don't

If you find yourself wanting to manage what was previously runtime state,
that's almost always a sign you're conflating "config" with "data":

- "I want to bake my elfeed feed list into nix" — feed list is config
  (manageable: write it to `~/.config/elfeed/feeds.org` via Pattern 1 or 3).
  The elfeed *database* is state (don't manage).
- "I want to seed an initial mu4e maildir" — maildir contents are state.
  But you might want to bake the mbsync configuration that *populates* the
  maildir (Pattern 1, already done in this repo).

The boundary: the *config* that tells the app where to write its state can
be managed. The state itself stays unmanaged.

## After every migration

```bash
# 1. Verify the final symlink layout:
ls -la ~/.<the-relevant-files>

# 2. Smoke test the app (where applicable):
msmtp -a <account> --serverinfo
mbsync -a -V

# 3. Commit:
git add -p modules/shared/config/<cat>/...
git add modules/shared/files.nix homes/<user>/home.nix
git commit -m "migrate <app> from <old-pattern> to <new-pattern>"
```

A migration that builds successfully but isn't smoke-tested is a migration
you'll have to debug under pressure later.
