{ config, pkgs, inputs, outputs, lib, ... }:
let user = "alan"; in
{

  imports = [
    #../../modules/darwin/home-manager.nix
    # ../../modules/shared
    # ../../modules/shared/cachix
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../common/darwin_home_manager.nix
    (import ../common/nix-homebrew.nix { inherit inputs; user = "${user}";})
    ../common/nix.nix
    ../common/substituters.nix
    
  ];


  services = {nix-daemon.enable = true; # Auto upgrade nix package and the daemon service.
              tailscale.enable = true; # Network of devices
  };
  

  # Setup user, packages, programs
  # nix = {
  #   # package = pkgs.nix;
  #   settings.trusted-users = [ "@admin" "${user}" ];

  #   gc = {
  #     user = "root";
  #     automatic = true;
  #     interval = { Weekday = 0; Hour = 2; Minute = 0; };
  #     options = "--delete-older-than 30d";
  #   };

  #   # Turn this on to make command line easier
  #   extraOptions = ''
  #     experimental-features = nix-command flakes
  #   '';
  # };

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  fonts = {
     packages = [ pkgs.dejavu_fonts pkgs.iosevka pkgs.nerdfonts ];
   };

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    emacs
    (pkgs.writeShellScriptBin "glibtool" "exec ${pkgs.libtool}/bin/libtool $@")
  ]; # ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  launchd.user.agents.emacs.path = [ config.environment.systemPath ];
  launchd.user.agents.emacs.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [
      "/bin/sh"
      "-c"
      "/bin/wait4path ${pkgs.emacs}/bin/emacs && exec ${pkgs.emacs}/bin/emacs --fg-daemon"
    ];
    StandardErrorPath = "/tmp/emacs.err.log";
    StandardOutPath = "/tmp/emacs.out.log";
  };

    system = {
  # Turn off NIX_PATH warnings now that we're using flakes
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "left";
        tilesize = 48;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
  
  # Configure nixpkgs
  nixpkgs = {
    # You can add overlays here
    overlays = builtins.attrValues outputs.overlays;
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # Create users
  users.users.${user} = {
    description = "Alan Munoz";
  
    home = "/Users/${user}";
    createHome = true;
    isHidden = false;
    #initialPassword = "password";
    shell = pkgs.fish;
    # openssh.authorizedKeys.keyFiles = [
    #   ../../homes/ank/id_rsa.pub
    #   ../../homes/ank/id_ed25519.pub
    # ];
  };


  # Configure homebrew
  homebrew = {
    enable = true;
    # brews = ["input-leap"]; # Example of brew
    taps = map (key: builtins.replaceStrings ["homebrew-"] [""] key) (builtins.attrNames config.nix-homebrew.taps);
    casks = pkgs.callPackage ../common/casks.nix {};
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };
  };


    # Configure home manager
    home-manager = {
      useGlobalPkgs = true;
      # Look into why enabling this break shell for starship
      # useUserPackages = true;
      extraSpecialArgs = {inherit inputs outputs;};
      users.${user}= {
        imports = [
          ../../homes/amunoz/home.nix
        ];
        home= {
          packages = pkgs.callPackage ../../modules/darwin/packages.nix {};
              };
      programs = {
        # This is important! Removing this will break your shell and thus your system
        # This is needed even if you enable zsh in home manager
        zsh.enable = true;
        fish.enable = true;
      } // import ../../modules/shared/home-manager.nix { inherit config pkgs lib; };
      };
    backupFileExtension = "bak";
    };

  # sudo with touch id
  security.pam.enableSudoTouchIdAuth = true;

  # remap keys : Caps -> Esc
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Disable press and hold for diacritics.
  # I want to be able to press and hold j and k
  # in vim to move around.
  # system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

}
