{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.local.aerospace;
  aerospaceApp = "${pkgs.aerospace}/Applications/AeroSpace.app";
  aerospaceDefaultConfig = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/nikitabobko/AeroSpace/v0.21.2-Beta/docs/config-examples/default-config.toml";
    hash = "sha256-pHUACO8I1pUMokopPxU0E0t5IvXypZj5reQZtQx7e4A=";
  };
  isLetterWorkspaceBinding =
    line:
    builtins.match "^[[:space:]]*alt-[a-z] = 'workspace [A-Z]'.*$" line != null
    || builtins.match "^[[:space:]]*alt-shift-[a-z] = 'move-node-to-workspace [A-Z]'.*$" line != null;
  aerospaceConfig = lib.concatStringsSep "\n" (
    builtins.filter (line: !isLetterWorkspaceBinding line) (
      lib.splitString "\n" (builtins.readFile aerospaceDefaultConfig)
    )
  );
  aerospaceLauncher = pkgs.writeShellScript "aerospace-launcher" ''
    layout_applied=false
    while true; do
      if [ "$layout_applied" = false ] && test -x /opt/homebrew/bin/displayplacer; then
        if /opt/homebrew/bin/displayplacer \
          "id:${cfg.builtInDisplayId} res:1470x956 hz:60 color_depth:8 enabled:true scaling:on origin:(-1470,0) degree:0" \
          "id:${cfg.horizontalDisplayId} res:1920x1200 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" \
          "id:${cfg.verticalDisplayId} res:1200x1920 hz:60 color_depth:8 enabled:true scaling:off origin:(1920,0) degree:90"
        then
          layout_applied=true
        fi
      fi
      if ! /usr/bin/pgrep -f '${aerospaceApp}/Contents/MacOS/AeroSpace' > /dev/null; then
        /usr/bin/open -g '${aerospaceApp}'
      fi
      /bin/sleep 10
    done
  '';
in
{
  options.local.aerospace = {
    enable = lib.mkEnableOption "AeroSpace window management";

    username = lib.mkOption {
      type = lib.types.str;
      description = "User whose AeroSpace configuration should be managed.";
    };

    builtInDisplayId = lib.mkOption {
      type = lib.types.str;
      default = "1";
      description = "displayplacer ID for the MacBook display.";
    };

    horizontalDisplayId = lib.mkOption {
      type = lib.types.str;
      default = "s944198732";
      description = "displayplacer ID for the horizontal Dell display.";
    };

    verticalDisplayId = lib.mkOption {
      type = lib.types.str;
      default = "s810438988";
      description = "displayplacer ID for the vertical Dell display.";
    };
  };

  config = lib.mkIf cfg.enable {
    homebrew.brews = [ "displayplacer" ];

    home-manager.users.${cfg.username}.home = {
      packages = [ pkgs.aerospace ];
      file.".aerospace.toml".text = aerospaceConfig + ''

        # Keep two numbered workspace sets aligned with the monitors from left to right.
        [workspace-to-monitor-force-assignment]
        1 = 1
        2 = 2
        3 = 3
        4 = 1
        5 = 2
        6 = 3
      '';
    };

    launchd.user.agents.aerospace.serviceConfig = {
      ProgramArguments = [ "${aerospaceLauncher}" ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
    };
  };
}
