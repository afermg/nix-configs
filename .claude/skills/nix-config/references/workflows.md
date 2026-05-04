# Workflows — rebuild, debug, update

Operational recipes for this repo. Includes host-specific quirks (the
hostname/flake-attr mismatch on `moby`), the kernel-update sequence, and
the macOS standalone home-manager path.

## The repo and the hosts

```
$REPO = /home/amunoz/.local/share/src/nixos-config

Linux/NixOS hosts:
  moby           — flake attr; actual hostname is gpa85-cad
                   (this is the live workstation)

Darwin standalone home-manager:
  alan@darwin001     — personal Mac
  amunozgo@darwin002 — work Mac
```

The mismatch between hostname (`gpa85-cad`) and flake attribute (`moby`) is
intentional — `moby` is a stable name for the role; the hostname can change
without rebuilding the flake. **Always pass `--flake $REPO#moby` explicitly**
to rebuild commands. Without `#moby`, nixos-rebuild looks for `.#gpa85-cad`
and errors with `error: file 'nixos-config' was not found`.

## NixOS rebuild commands

```bash
# Validate eval, build the closure, but DON'T activate.  Useful for "does
# this change cause an eval/build error?" without committing.
nixos-rebuild build --flake $REPO#moby

# Activate now (running services restart, dotfiles relink, generations bump).
sudo nixos-rebuild switch --flake $REPO#moby

# Write the bootloader entry but do NOT activate.  Use for kernel updates
# when you want to pick the moment to reboot.
sudo nixos-rebuild boot --flake $REPO#moby

# Test the new generation but DON'T persist (won't survive reboot).  Useful
# for testing risky changes; reboot if anything breaks.
sudo nixos-rebuild test --flake $REPO#moby
```

**`build` vs `switch`** — `build` only validates and produces the closure;
the symlinks under `~/` aren't updated, services don't restart, dotfiles
don't relink. If you ran `build` and "the change didn't take effect", run
`switch`.

**`boot` vs `switch`** — `boot` writes the bootloader entry but doesn't
activate the new generation in the running system. The new kernel/initrd
loads on next boot. `switch` activates immediately AND writes the boot entry,
but kernel changes still need a reboot to take effect (running kernel
doesn't get hot-swapped). Use `boot` when you have a kernel update queued
and want to reboot at your convenience.

## Darwin standalone home-manager

```bash
# First time on a new Mac:
nix run home-manager/master -- switch --flake $REPO#alan@darwin001
# (or amunozgo@darwin002 for the work machine)

# After that, home-manager is on PATH:
home-manager switch --flake $REPO#alan@darwin001
```

No `sudo`. Standalone home-manager only writes to `~/.nix-profile`, `~/.config`,
`~/Library`, etc.

The `darwin001`/`darwin002` part is just an attribute label, not a hostname.
The Mac doesn't need to be named that.

## Kernel updates (the copy.fail / CVE workflow)

```bash
# 1. Bump the input.
nix flake update nixpkgs                     # in $REPO

# 2. Verify the new kernel version (eval-only, fast):
nix eval --raw --impure --expr \
  'let pkgs = import (builtins.getFlake "'"$REPO"'").inputs.nixpkgs \
     { system = "x86_64-linux"; }; in pkgs.linux.version'
# Should report 6.18.24 or whatever.

# 3. Stage the new generation in the bootloader without activating:
sudo nixos-rebuild boot --flake $REPO#moby

# 4. Reboot when convenient:
sudo reboot

# 5. After reboot, confirm:
uname -r                                     # should show the new version
```

The `boot`-then-reboot sequence is preferred over `switch`-then-reboot when
the *only* reason for the rebuild is the kernel — `boot` doesn't restart
running services or relink dotfiles, so you don't get spurious flapping.

If you want immediate effect for non-kernel changes too:
```bash
sudo nixos-rebuild switch --flake $REPO#moby
sudo reboot                                  # only if kernel changed
```

## The git tracking gotcha

Flakes only see git-tracked files. Three failure modes:

1. **Brand-new file referenced from a `.nix` module** —
   `error: getting status of '...': No such file or directory` even though
   `ls` shows the file exists. Fix: `git add -N <file>` (intent-to-add adds
   the file to the index without committing).

2. **`.gitignore`'d file referenced** — same error as above. Either un-ignore
   or use `?ref=git+file:?dir=...` semantics (rare).

3. **`mkOutOfStoreSymlink` target untracked** — eval succeeds but activation
   creates a dangling symlink. Discover this when the app says "config not
   found". Fix: `git add` the target.

The "git tree is dirty" warning during rebuild is informational, not an
error. Commit before rebuild for reproducibility (the closure hash differs
between dirty and clean states), but it's not strictly required.

## Adding things

### A package from nixpkgs

```nix
# modules/shared/packages.nix
{ pkgs, ... }:
with pkgs; [
  msmtp                    # add new package here
  isync
  mu
  # ...
]
```

Single source of truth for shared packages. Per-host additions go in the
host's own packages list (e.g., `machines/moby/packages.nix` if it exists).

### A package from an external flake

```nix
# flake.nix
{
  inputs = {
    # ...
    my-tool.url = "github:owner/repo";
    my-tool.inputs.nixpkgs.follows = "nixpkgs";   # optional but tidy
  };

  outputs = { self, nixpkgs, my-tool, ... }@inputs:
    # ...
}
```

```nix
# overlays/default.nix
{ inputs, ... }:
{
  my-tool = final: _: {
    my-tool = inputs.my-tool.packages.${final.stdenv.hostPlatform.system}.default;
  };
}
```

After this, `pkgs.my-tool` is available everywhere. If the upstream flake
ships its own overlay (emacs-overlay does), prefer that:

```nix
# overlays/default.nix
{
  emacs = inputs.emacs-overlay.overlay;   # use upstream's overlay directly
}
```

### A new dotfile

1. Pick a pattern (see `patterns.md` and the decision algorithm in
   `SKILL.md`).
2. Create a standalone `.nix` module under `modules/shared/config/<cat>/`
   (or `modules/<host>/...` if host-specific).
3. Import from the relevant home — typically `homes/amunoz/home.nix`'s
   `imports = [ ... ];`.
4. `git add` the new module AND any tracked content files.
5. `nixos-rebuild build --flake $REPO#moby` to validate, then `switch`.

### A new flake input (full lifecycle)

**Adding:**
1. Add under `inputs = {...}` in `flake.nix`.
2. Add to the `outputs = { ..., <name>, ... }@inputs:` destructured arg list
   if `outputs` consumes it directly.
3. `nixos-rebuild build --flake $REPO#moby` — this fetches the input.
4. The fetched lock entry lands in `flake.lock` automatically.

**Removing:**
1. Delete the entry from `inputs`.
2. Delete from the `outputs` destructured arg list.
3. **Search for and remove any commented references** in module files (e.g.
   `# overleaf.nixosModules.default`). The rebuild won't catch these but they
   confuse readers and rot.
4. Remove any `pkgs.<thing>` references the input was the source of.
5. Rebuild to clean up `flake.lock`.

## Debugging rebuild failures (full triage)

In rough order of how often they hit, with the actual error text:

### `error: file 'nixos-config' was not found in the Nix search path`

You ran `nixos-rebuild` without `--flake`. Add `--flake $REPO#moby`. This
also happens to scripts that wrap rebuild — make sure the wrapper passes
the flake.

### `error: getting status of '...': No such file or directory`

A `.nix` module references a file that isn't in the git index. `git add -N
<file>` (intent-to-add) is the lightest fix; `git add` + `git commit`
are heavier but cleaner.

### `error: The option '<path>.<field>' was accessed but has no value defined`

A home-manager module needs more fields. Common offenders:
- `accounts.email.accounts.<n>.realName` (required, not optional)
- `accounts.email.accounts.<n>.userName` (required if not = address)
- `programs.git.signing.key` when signing is enabled

Check the option's docs (`home-manager-options` or
`https://home-manager-options.extranix.com/`) and add the missing field.

### `chmod: changing permissions of '...': Read-only file system`

Activation tried to `chmod` a file that's a symlink into `/nix/store`. The
target is read-only. Symptoms: the home-manager activation service fails
in `systemctl status home-manager-<user>.service`. Switch to a different
pattern — usually Pattern 2 (home-manager module) or Pattern 3 (out-of-store
symlink). See `migrations.md` for how.

### `error: attribute 'X' missing`

The flake doesn't have an attribute by that name. Two common causes:
- You ran `nixos-rebuild --flake $REPO#unknown-host` — check the host name.
- An overlay or module references a package/input that was removed but not
  fully cleaned up.

### `home-manager-<user>.service: Failed with result 'exit-code'`

Build succeeded but home-manager activation failed. Check the unit logs:
```bash
systemctl status home-manager-amunoz.service
journalctl -xeu home-manager-amunoz.service
```
The actual error is usually in the last 20 lines.

### Eval succeeds, activation succeeds, but the change isn't visible

You ran `build`, not `switch`. `build` only produces the closure; it doesn't
update `~/`. Run `sudo nixos-rebuild switch --flake $REPO#moby`.

For kernel-related changes specifically: `switch` doesn't reboot; the new
kernel won't be running until you `sudo reboot`.

## Resuming after a crash / generation rollback

```bash
# List recent generations:
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Roll back to the previous generation (immediate, no rebuild):
sudo nix-env --rollback --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch

# Or boot into a specific generation: pick it from the bootloader menu.
```

The bootloader retains the last several generations as bootable entries.
If a `switch` breaks the system, reboot and pick a previous generation.
