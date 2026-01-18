{
  pkgs,
  outputs,
  config,
  inputs,
  ...
}:
let
  user = if pkgs.stdenv.isLinux then "amunoz" else "amunozgo";
  home_parent = if pkgs.stdenv.isLinux then "home" else "Users";
  atuin_key_path = if pkgs.stdenv.isLinux then { key_path = config.age.secrets.atuin.path; } else { };
  atuin_daemon_p = if pkgs.stdenv.isLinux then true else false;
in
{

  nixpkgs = {
    overlays = [
      outputs.overlays.emacs
      outputs.overlays.stable
    ];
  };

  home = {
    username = "${user}";
    homeDirectory = "/${home_parent}/${user}";

    stateVersion = "24.05";
    packages = pkgs.callPackage ./packages.nix { };
    #file = import ../../modules/shared/files.nix { inherit config pkgs; };
  };

  # Gnome graphical interface
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:swapescape" ];
    };
    "org/gnome/shell".enabled-extensions = [
      "forge@jmmaranan.com"
      "appindicatorsupport@rgcjonas.gmail.com"
    ];
    # Custom keybindings
    "org/gnome/desktop/wm/keybindings" = {
      activate-window-menu = "disabled";
      toggle-message-tray = "disabled";
      minimize = [ ];
      move-to-monitor-left = [ ];
      move-to-monitor-right = [ ];
      hide-window = [ ];
      close = [ "<Super>q" ];
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-left = [ "<Control><Shift><Super>h" ];
      move-to-workspace-right = [ "<Control><Shift><Super>l" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-left = [ "<Shift><Control>h" ];
      switch-to-workspace-right = [ "<Shift><Control>l" ];
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

  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age = {
    identityPaths = [ "/${home_parent}/${user}/.ssh/id_ed25519" ];
    secrets.atuin.file = ../../secrets/atuin.age;
  };

  programs.atuin = {
    enable = true;
    # package = pkgs.stable.atuin;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "prefix";
      daemon = {
        enabled = atuin_daemon_p;
        socket_path = "/home/amunoz/.local/share/atuin/atuin.sock";
      }
      // atuin_key_path;
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "fishbang";
        src = pkgs.fishPlugins.fishbang.src;
      }
      {
        name = "fish-you-should-use";
        src = pkgs.fishPlugins.fish-you-should-use.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
      {
        name = "async-prompt";
        src = pkgs.fishPlugins.async-prompt.src;
      }
      # Incompatible with async
      # {
      #   name = "transient-fish";
      #   src = pkgs.fishPlugins.transient-fish.src;
      # }
    ];
    # Atuin+fzf history from https://github.com/atuinsh/atuin/issues/68
    interactiveShellInit = ''
      set --universal pure_enable_nixdevshell true

      # Ation + fzf
      function fzf_history
          set -l line (commandline)

          # tac reverses order initially, tiebreak sorts(?), -n2..,.. ignores first two fields, +m means no "--multi"
          set -l result (atuin search --cmd-only | fzf --tac "-n2..,.." --tiebreak=index "+m" --query="$line")

          set -l key $result[1]
          set -l selected $result[2]

          if test "$key" = enter
              commandline --replace $selected
              commandline -f repaint
              commandline -f execute
              return
          end

          if test -n "$selected"
              commandline -r -- $selected
          end

          commandline -f repaint
      end
      set -gx FZF_DEFAULT_OPTS "--bind=alt-k:up,alt-j:down --expect=tab,enter --layout=reverse 
        --height=17 --delimiter='\t' --with-nth=1 
          --preview-window='border-rounded' --prompt='  ' --marker=' ' --pointer=' ' 
          --separator='─' --scrollbar='┃' --layout='reverse' 
        "
      set -x ATUIN_NOBIND = true
      bind \cR fzf_history
    '';
  };

  # systemd.user.services = {
  #   atuin_daemon = {
  #     Unit = {
  #       Description = "Run the atuin daemon";
  #       Documentation = [
  #         "man:example(1)"
  #         "man:example(5)"
  #       ];
  #     };
  #     Install = {
  #       WantedBy = [ "default.target" ];
  #     };
  #     Service = {
  #       ExecStart = "${pkgs.writeShellScript "atuin-daemon" ''
  #         #!/run/current-system/sw/bin/bash
  #         rm -r ~/.local/share/atuin/atuin.sock
  #         nohup atuin daemon &
  #       ''}";
  #       Type = "oneshot";
  #     };
  #   };
  # };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Alán F. Muñoz";
      user.email = "afer.mg@gmail.com";
    };
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
