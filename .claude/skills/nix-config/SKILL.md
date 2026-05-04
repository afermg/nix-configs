---
name: nix-config
description: |
  Use this skill whenever you're working in this NixOS + home-manager config repo
  and the user is adding, removing, modifying, organizing, or troubleshooting any
  declarative configuration. Trigger eagerly on questions like "where should this
  dotfile live?", "how do I add this package?", "why is rebuild failing?",
  "should this be a symlink or baked in?", on any pasted snippet of `flake.nix` /
  `*.nix` content, on requests to migrate a config between patterns (raw file →
  home-manager module, etc.), and on kernel/system-update workflows. Also use
  when the user mentions a specific app whose config might live in this repo
  (emacs, claude, msmtp, mbsync, rbw, fish, git, …) — the skill encodes which
  management pattern fits each one and how to migrate. Better to invoke and
  not need it than to silently make a mistake the rebuild won't catch.
---

# nix-config — repo management for this NixOS + home-manager flake

This repo is a single-flake NixOS + home-manager configuration. Two NixOS
hosts (`moby` is the live one, hostname `gpa85-cad`) and a couple of darwin
hosts share modules under `modules/shared/` and per-user homes under
`homes/<user>/`. This skill encodes the patterns this user has converged on
through real maintenance pain — read it before adding configuration and you'll
avoid traps the rebuild won't catch (read-only `/nix/store` writes, untracked
files invisible to flakes, kernel-update activation order, etc.).

## The central decision: where does a config live?

The first question for any new configuration is **how often does it change, and
who writes to it**. Pick the pattern that matches both:

| Volatility | Who writes | Pattern | Example |
|---|---|---|---|
| Never | You, in nix code | **Nix-baked file** (`text = builtins.readFile ...` or `text = builtins.toJSON ...`) | `flake.nix`, fixed package lists, NixOS module structure |
| Rare (months) | You, but format/perms quirky | **Dedicated home-manager module** (`programs.<x>.enable = true`) | msmtp, mbsync, git, fish |
| Frequent (days–weeks) | You + sometimes a tool | **Out-of-store symlink** (`config.lib.file.mkOutOfStoreSymlink`) | emacs `init.el`, claude `settings.json` |
| Runtime, by another tool | The app itself | **Unmanaged** (don't put it in nix at all) | mu4e index, mbsync maildirs, elfeed db, shell history |

There's a fifth pattern — **`home.activation` seed** (write once, then leave
alone) — that looks tempting but is almost always inferior to
`mkOutOfStoreSymlink`. See `references/patterns.md` for why.

For the full taxonomy with concrete examples from this repo, see
`references/volatility-taxonomy.md`.

## Quick decision algorithm

When the user wants to add or migrate a config, walk this in order — stop at
the first match:

1. **Does another process write to the file at runtime?** (Claude editing
   `settings.json`, mu4e maintaining its index, mbsync moving mail)
   → If the writes should *survive rebuilds*, use **out-of-store symlink** to a
     repo file (writes flow back to git). If the writes are pure runtime state
     you don't want to track, **leave it unmanaged**.
2. **Does the app enforce strict file permissions or have an unusual format?**
   (msmtp wants 0600 when there's a literal password; some apps want a specific
   xdg path)
   → Use the **dedicated home-manager module** if one exists
     (`programs.msmtp.enable = true` + `accounts.email.accounts.<n>`). It writes
     a real file with correct perms in the right place.
3. **Will you edit this file directly more than once a month?** (emacs config,
   claude prompts, project-specific stuff)
   → Use **out-of-store symlink** to a tracked repo file. Edit, commit, no
     rebuild needed.
4. **Is the content static or rarely-changing, and authored entirely in nix?**
   (a JSON config, an mbsyncrc you tweak twice a year)
   → Use **nix-baked**: `home.file.".foo".text = builtins.toJSON {...};` or
     `text = builtins.readFile ../shared/config/foo/foorc;`.

If none fit cleanly, default to nix-baked and revisit if you find yourself
running `nixos-rebuild switch` just to test a one-line change.

## The four patterns, briefly (full examples in `references/patterns.md`)

### 1. Nix-baked file

```nix
# modules/shared/files.nix
".mbsyncrc" = {
  text = builtins.readFile ../shared/config/email/mbsyncrc;
};
```

The file lives in `/nix/store` (mode 0444) and `~/.mbsyncrc` symlinks to it.
**Trap:** `onChange = "chmod 600 $HOME/.foorc"` will FAIL — the target is
read-only. If the app needs strict perms, this pattern is wrong; use #2.

### 2. Dedicated home-manager module

```nix
# homes/amunoz/home.nix
programs.msmtp.enable = true;
accounts.email = {
  maildirBasePath = ".mail";
  accounts.broad = {
    realName = "...";
    address = "...";
    userName = "...";
    passwordCommand = [ "rbw" "get" "'Broad Email App Password'" ];
    smtp = { host = "smtp.gmail.com"; port = 465; tls.useStartTls = false; };
    msmtp.enable = true;
  };
};
```

Module writes to `~/.config/msmtp/config` (XDG path) with appropriate handling.
**Trap:** `passwordCommand` is rendered with plain `toString` (no shell
escaping). Multi-word args like rbw entry names with spaces must embed their
own single quotes: `[ "rbw" "get" "'Broad Email App Password'" ]`. See
`references/patterns.md` for the full list of these per-module gotchas.

### 3. Out-of-store symlink (`mkOutOfStoreSymlink`)

```nix
# modules/shared/config/claude/claude.nix
{ config, ... }:
{
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/claude/settings.json";
}
```

`~/.claude/settings.json` is a symlink straight back to the repo file. You
(and Claude itself, via `/permissions`) can edit it directly; changes show up
in `git status`. **Trap:** the target file must be `git add`'d for the flake
to see it.

### 4. Unmanaged — DO NOT put in nix

Mu4e's `~/.mail/` maildirs, elfeed's `~/.config/elfeed/db/`, fish's history
file, claude's `~/.claude/projects/<...>/<sid>.jsonl` transcripts. These are
runtime state owned entirely by the app. Putting them under nix breaks the
app or forces awkward seeding logic with no upside.

## Common workflows in this repo

For full recipes (with the actual flake-attr names and host quirks), see
`references/workflows.md`. The TL;DR:

- **Build only** (validate eval): `nixos-rebuild build --flake $REPO#moby`
- **Boot entry, no activation** (kernel updates, reboot later):
  `sudo nixos-rebuild boot --flake $REPO#moby` then reboot at your leisure
- **Activate now**: `sudo nixos-rebuild switch --flake $REPO#moby`
- **`#moby` is required** — the host's hostname is `gpa85-cad` but the flake
  attribute is `moby`. Without `#moby`, rebuild looks for `.#gpa85-cad` and
  errors out.
- **macOS**: `home-manager switch --flake $REPO#alan@darwin001` (standalone
  home-manager; no `sudo`, no nix-darwin needed unless you want declarative
  system defaults).
- **Untracked files**: flakes only see git-tracked files. Before referencing
  a brand-new file from a `.nix` module, `git add -N <file>` (intent-to-add)
  or commit it. Without this, eval fails with `path '...' does not exist`.

## Adding things to the repo

For each kind of addition, see the corresponding section of
`references/workflows.md`:

- **A new package from nixpkgs** — append to `modules/shared/packages.nix` (or
  the relevant per-host packages list).
- **A package from an external flake** — add the flake input in `flake.nix`,
  expose via `overlays/default.nix` so `pkgs.<name>` works everywhere. If the
  upstream flake provides its own overlay (emacs-overlay does), prefer that.
- **A new dotfile** — pick a pattern with the decision algorithm above; create
  a standalone `.nix` module under `modules/shared/config/<category>/`; import
  it from `homes/<user>/home.nix` via `imports = [ ... ];`.
- **A new flake input** — add under `inputs = {...}` in `flake.nix`. If the
  input is consumed by `outputs`, also add it to the destructured arg list:
  `outputs = { self, nixpkgs, home-manager, agenix, <new-input>, ... }@inputs:`.
  When *removing* an input later, drop both the `inputs` line AND the
  destructured arg AND any commented references in module files (the rebuild
  doesn't catch dangling commented-out references but they confuse readers).

## Migrating between patterns

The most common migrations in this repo and the gotchas you'll hit are in
`references/migrations.md`. Highlights:

- **Raw `home.file` → home-manager module**: necessary when the raw approach
  fails on permission checks (msmtp 0600, ssh 0600, gpg 0700). Required steps:
  delete the `home.file` entry, add the `programs.<x>.enable` block, **`rm`
  the stale symlink at the old path** (or activation will refuse to overwrite
  it), `nixos-rebuild switch` (not just `build`), verify the new path exists.
- **`home.file` (nix-baked) → out-of-store symlink**: when you start editing
  the file enough that "edit, rebuild, test, repeat" feels heavy. Move the
  content to a tracked repo file, swap to `mkOutOfStoreSymlink`, `git add`
  the file, switch.
- **Out-of-store symlink → home-manager module**: rarely needed. Only when an
  app starts enforcing perms or path conventions you can't satisfy by symlink.

## Debugging rebuild failures

A short triage list. For deeper details, see `references/workflows.md`.

1. **`error: file 'nixos-config' was not found in the Nix search path`** — you
   ran `nixos-rebuild` *without* `--flake`. Add `--flake $REPO#moby`.
2. **`path '...' does not exist`** — referenced a file that isn't `git add`'d.
   `git add -N <file>` or commit it.
3. **`option '...' has no value defined`** — a home-manager module needs more
   fields. `accounts.email.accounts.<n>.realName` is a common one (required
   even though it feels optional).
4. **`Read-only file system` in home-manager activation** — you're trying to
   `chmod` or write through a `/nix/store` symlink. Use a different pattern
   (see decision algorithm above).
5. **Eval succeeds but the change doesn't appear** — you ran `build`, not
   `switch`. `build` only validates the closure; it doesn't activate.
6. **Kernel didn't update on reboot** — kernel changes need `boot` (writes the
   bootloader entry) + a real reboot. `switch` updates running services but
   not the kernel; you'll boot the new kernel only on next reboot.

## Reference files

The detailed material lives under `references/`:

- `references/volatility-taxonomy.md` — the four tiers in depth, with one
  worked example per tier from this repo.
- `references/patterns.md` — full code for all five management patterns
  (including the rare `home.activation` seed), with per-pattern gotchas.
- `references/workflows.md` — rebuild commands, host-specific quirks, kernel
  updates, the macOS standalone home-manager path, untracked-file traps.
- `references/migrations.md` — recipes for moving a config between patterns
  with the exact cleanup steps to avoid leftover stale symlinks.

Read the relevant reference for any task that goes beyond a one-line change.
The skill body is intentionally compact; the references are where the real
operational detail lives.
