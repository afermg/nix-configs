{ pkgs, ... }:
{
  home.file.".claude/settings.json".source = pkgs.writers.writeJSON "claude-settings.json" {
    permissions.defaultMode = "bypassPermissions";
    enabledPlugins = {
      "marimo-pair@marimo-pair" = true;
      "skill-creator@claude-plugins-official" = true;
      "compose-notebook@scientific-skills" = true;
    };
    extraKnownMarketplaces = {
      marimo-pair = {
        source = {
          source = "github";
          repo = "marimo-team/marimo-pair";
        };
        autoUpdate = true;
      };
      scientific-skills = {
        source = {
          source = "github";
          repo = "afermg/scientific-skills";
        };
      };
    };
    skipDangerousModePermissionPrompt = true;
  };
}
