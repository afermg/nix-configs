{ config, ... }:
{
  # Same live-repo pattern as Claude Code: keep the tracked config file as the
  # single source of truth, but expose it at ~/.codex/config.toml via an
  # out-of-store symlink so edits land on the repo file immediately.
  home.file.".codex/config.toml".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/codex/config.toml";

  # User-wide instructions loaded into every Codex session.
  home.file.".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/codex/AGENTS.md";

  # Mirror the small set of personal/global skills that are also exposed to
  # Claude Code.
  home.file.".codex/skills/trip-reconcile".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/Documents/broad/org/.claude/skills/trip-reconcile";

  # Keep the Emacs bridge available to Codex as a first-class global skill.
  home.file.".codex/skills/emacs-pair".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/projects/emacs-pair";
}
