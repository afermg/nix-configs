{ pkgs, outputs, ... }:
let user = if pkgs.stdenv.isLinux
           then "amunoz"
           else "amunozgo";
    home_parent = if pkgs.stdenv.isLinux
                  then "home"
                  else "Users";
in
{
  nixpkgs = {
    overlays = [
      outputs.overlays.emacs
    ];
  };
  
  home = {
       username = "${user}";
       homeDirectory = "/${home_parent}/${user}";
                       
       stateVersion = "24.05";
       packages = (pkgs.callPackage ./packages.nix {});
       #file = import ../../modules/shared/files.nix { inherit config pkgs; };
  };


  # Gnome graphical interface
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
        toggle-message-tray = "disabled";
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
          # binding = "<Super>Return"; # conflicts with forge, see  https://github.com/forge-ext/forge/issues/37
          binding = "<Shift><Alt>t";
          command = "wezterm";
          name = "Terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Super>w";
          command = "/usr/bin/env firefox";
          name = "Firefox";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          binding = "<Super>e";
          command = "/usr/bin/env emacsclient -c -a emacs";
          name = "Emacs";
        };
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
  };
  
  programs.git = {
    enable = true;
    userName = "Alán F. Muñoz";
    userEmail = "afer.mg@gmail.com";
    #extraConfig = {
    # Sign all commits using ssh key
    #    commit.gpgsign = true;
    #    gpg.format = "ssh";
    #    gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    #    user.signingkey = "~/.ssh/id_ed25519.pub";
    #  };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  
}
