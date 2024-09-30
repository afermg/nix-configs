{ config, pkgs, lib, ... }:

let
  user = "amunoz";
  # xdg_configHome  = "/home/${user}/.config";
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
  # shared-files = import ../shared/files.nix { inherit config pkgs; };

in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    # file = shared-files // import ./files.nix { inherit user; };
    stateVersion = "21.05";
  };

  # Use a dark theme
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  # Screen lock
  services = {
    # Auto mount devices
    # udiskie.enable = true;

    dunst = {
      enable = true;
      package = pkgs.dunst;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          border = 0;
          height = 400;
          width = 320;
          offset = "33x65";
          indicate_hidden = "yes";
          shrink = "no";
          separator_height = 0;
          padding = 32;
          horizontal_padding = 32;
          frame_width = 0;
          sort = "no";
          idle_threshold = 120;
          font = "Noto Sans";
          line_height = 4;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          transparency = 10;
          show_age_threshold = 60;
          word_wrap = "yes";
          ignore_newline = "no";
          stack_duplicates = false;
          hide_duplicate_count = "yes";
          show_indicators = "no";
          icon_position = "left";
          icon_theme = "Adwaita-dark";
          sticky_history = "yes";
          history_length = 20;
          history = "ctrl+grave";
          browser = "google-chrome-stable";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          max_icon_size = 64;
        };
      };
    };
  };

  programs = shared-programs // {};

  dconf.settings = {
  "org/gnome/settings-daemon/plugins/power" = {
    sleep-inactive-ac-type = "nothing";
    };
   "org/gnome/desktop/input-sources" = {
        xkb-options = ["caps:swapescape"];
      };
    "org/gnome/shell".enabled-extensions = [
      "forge@jmmaranan.com"
      "appindicatorsupport@rgcjonas.gmail.com"
    ];
      # Custom keybindings
      "org/gnome/desktop/wm/keybindings" = {
        activate-window-menu = "disabled";
        # toggle-message-tray = "disabled";
        minimize = [];
        move-to-monitor-left=[];
        move-to-monitor-right=[];
        hide-window=[];
        close = ["<Super>q"];
        move-to-workspace-1=["<Shift><Super>1"];
        move-to-workspace-2=["<Shift><Super>2"];
        move-to-workspace-3=["<Shift><Super>3"];
        move-to-workspace-4=["<Shift><Super>4"];
        move-to-workspace-left=["<Control><Shift><Super>h"];
        move-to-workspace-right=["<Control><Shift><Super>l"];
        switch-to-workspace-1=["<Super>1"];
        switch-to-workspace-2=["<Super>2"];
        switch-to-workspace-3=["<Super>3"];
        switch-to-workspace-4=["<Super>4"];
        switch-to-workspace-left=["<Shift><Control>h"];
        switch-to-workspace-right=["<Shift><Control>l"];
      };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>Return"; # conflicts with forge, see  https://github.com/forge-ext/forge/issues/37
          # binding = "<Super>t";
          command = "/usr/bin/env kitty";
          name = "Terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Super>e";
          command = "/usr/bin/env emacsclient -c -a emacs";
          name = "Emacs";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          binding = "<Super><Shift>Return";
          command = "firefox";
          name = "Emacs";
        };
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
  };
  
}
