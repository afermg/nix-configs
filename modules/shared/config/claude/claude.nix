{ config, ... }:
{
  # ~/.claude/settings.json is an out-of-store symlink resolving to the repo
  # file. Note the two-hop indirection: home-manager registers the entry inside
  # the generation's `home-manager-files` store dir, so `ls -l` shows the link
  # pointing into /nix/store — but that store entry is itself a symlink to the
  # absolute repo path, so `readlink -f` resolves all the way back to the repo
  # file. This is NOT nix-baked (Pattern 1), where the store target would be a
  # read-only *copy*; here the final target is the live, writable repo file.
  # The repo path stays the single source of truth (declarative, version-
  # controlled), and Claude can edit it directly via /permissions, /plugin add,
  # etc. — those edits land on the tracked file immediately (no rebuild) and
  # show up in `git status` for review/commit. Same trick used for emacs init.el.
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
