# Neusis

Nix configs for linux and macos machines. 

## Getting started

linux machines

```bash
nixos-rebuild switch --flake .#moby
```

macos machines

```bash
darwin-rebuild switch --flake .#darwin001
```

This combines [this](https://github.com/afermg/clouds) and [this](https://github.com/afermg/nix-config) configurations to consolidate Linux and MacOS into one.
