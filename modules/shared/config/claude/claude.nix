{ config, ... }:
{
  # ~/.claude/settings.json is an out-of-store symlink straight back to the
  # repo file. The repo path stays the single source of truth (declarative,
  # version-controlled), and Claude can edit it directly via /permissions,
  # /plugin add, etc. — those edits land on the tracked file and show up in
  # `git status` for review/commit. Same trick used for emacs init.el.
  home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/claude/settings.json";

  # User-wide instructions loaded into every Claude Code session. Same
  # out-of-store rationale as settings.json: edits land on the tracked repo
  # file and show up in `git status`.
  home.file.".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/claude/CLAUDE.md";

  # Personal skills live in the broad/org private repo (so they're tracked
  # alongside the data they operate on — trip-reconcile reads finance/trips.org
  # and finance/cc_*.csv). The skill is symlinked into ~/.claude/skills/ so
  # Claude Code discovers it system-wide, regardless of which directory it
  # runs from.
  home.file.".claude/skills/trip-reconcile".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/Documents/broad/org/.claude/skills/trip-reconcile";
}
