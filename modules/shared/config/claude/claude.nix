{ config, ... }:
{
  # ~/.claude/settings.json is an out-of-store symlink straight back to the
  # repo file. The repo path stays the single source of truth (declarative,
  # version-controlled), and Claude can edit it directly via /permissions,
  # /plugin add, etc. — those edits land on the tracked file and show up in
  # `git status` for review/commit. Same trick used for emacs init.el.
  home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/claude/settings.json";
}
