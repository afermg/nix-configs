# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-pc-ssd
    inputs.home-manager.nixosModules.home-manager

    # Import your generated (nixos-generate-config) hardware configuration
    # Disko configuration
    inputs.disko.nixosModules.disko
    ./disko.nix
    ../common/vm.nix
    # Path to make boot work with zstore pool
    ./hardware-configuration.nix

    # You can also split up your configuration and import pieces of it here:
    ./boot.nix
    ../common/networking.nix
    ../common/printing.nix
    ../common/gpu/nvidia.nix
    ../common/substituters.nix
    ../common/pipewire.nix
    ../common/virtualization.nix
    ../common/input_device.nix
    ../common/ssh.nix
    ../common/us_eng.nix
  ];

  # FHS
  programs.nix-ld.enable = true;

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      autoSuspend = false;
    };

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      xkb.layout = "us";
    };

    # Ollama service
    ollama = {
      enable = true;
      package = pkgs.ollama;
      acceleration = "cuda";
      environmentVariables = {
        CUDA_VISIBLE_DEVICES = "0";
        LD_LIBRARY_PATH = "${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudatoolkit}/lib64";
      };
    };

    # Apache tika: Processs documents for LLM ingestion
    tika.enable = true;

    # Emacs: The one and only True Editor.
    emacs = {
      enable = true;
      # Xwidgets are not working # https://github.com/nix-community/emacs-overlay/issues/455
      package = pkgs.emacs.override {
        withImageMagick = true;
        withXwidgets = false;
      };
    };

    age.secrets.mysecrets.file = ../../secrets/tailscale.age;

    tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.mysecrets.path;
    };

  };

  nixpkgs = {
    # You can add overlays here
    overlays = builtins.attrValues outputs.overlays;
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
    (lib.filterAttrs (_: lib.isType "flake")) inputs
  );

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  fonts.packages = with pkgs; [
    emacs-all-the-icons-fonts
    font-awesome
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    jetbrains-mono
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerd-fonts.iosevka
  ];

  # Default system wide packages
  environment.systemPackages = pkgs.callPackage ../../modules/nixos/packages.nix { } ++ [
    inputs.agenix.packages.${pkgs.system}.default
  ];
  environment.shells = [
    pkgs.zsh
    pkgs.fish
  ];
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # For blender
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Networking
  networking.hostName = "gpa85-cad";
  networking.hostId = "5a08e8de";
  # networking.bridges.br0.interfaces = [ "enp2s0" "wlp131s0" ];
  # enable the netbird service
  # services.netbird.enable = true;
  # environment.systemPackages = [ pkgs.netbird-ui ]; # for GUI

  # services.syncthing = {
  #   enable = true;
  #   #user = "syncthing";
  #   #dataDir = "/home/amunoz/sync";
  #   #configDir = "/home/amunoz/Documents/.config/syncthing";   # Folder for Syncthing's settings and keys
  #   overrideDevices = true;     # overrides any devices added or deleted through the WebUI
  #   #overrideFolders = true;     # overrides any folders added or deleted through the WebUI
  #   settings = {
  #     devices = {
  #       "broad" = { id = "CD7FTGY-ERFLZFS-FBW4K5L-TPW3IQ4-TZ36LIC-AUO3IGE-66LGSRI-5DTEBAG"; };
  #       "main" = { id = "TKXRRWK-K5EDNVM-AVXZKCP-TE2M2LC-A7CYJB7-LY2G5MU-EYGHIZC-I6GMRAR"; };
  #     };
  #     };
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.amunoz = {
    shell = pkgs.fish;
    isNormalUser = true;
    initialPassword = "changeme";
    description = "Alan Munoz";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "qemu-libvirtd"
      "input"
    ];
    openssh.authorizedKeys.keyFiles = [
      ../../homes/amunoz/id_ed25519.pub
    ];
  };

  users.users.llanos = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "Paula Llanos";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "qemu-libvirtd"
      "input"
    ];
    openssh.authorizedKeys.keyFiles = [
      ../../homes/llanos/id_rsa.pub
    ];
  };

  users.users.hhakem = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Hugo Hakem";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "qemu-libvirtd"
      "input"
    ];
    openssh.authorizedKeys.keyFiles = [
      ../../homes/hhakem/id_rsa.pub
    ];
  };

  users.users.zchen = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Zitong Chen";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "qemu-libvirtd"
      "input"
    ];
    openssh.authorizedKeys.keyFiles = [
      ../../homes/zchen/id_rsa.pub
    ];
  };

  users.users.akalinin = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Alex Kalinin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "qemu-libvirtd"
      "input"
    ];
    openssh.authorizedKeys.keyFiles = [
      ../../homes/akalinin/id_rsa.pub
    ];
  };

  users.users.jfredinh = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Johan Fredinh";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "qemu-libvirtd"
      "input"
    ];
    openssh.authorizedKeys.keyFiles = [
      ../../homes/jfredinh/id_ed25519.pub
    ];
  };

  # Enable home-manager for users
  # home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs outputs; };
  home-manager.backupFileExtension = "backups";

  # USER HOMES
  # home-manager.users.amunoz = import ../../modules/nixos/home-manager.nix;
  home-manager.users.amunoz = {
    imports = [
      # ../../modules/nixos/home-manager.nix;
      inputs.agenix.homeManagerModules.default
      ../../homes/amunoz/moby.nix
    ];
  };

  home-manager.users.llanos = {
    imports = [
      inputs.agenix.homeManagerModules.default
      ../../homes/llanos/moby.nix
    ];
  };

  home-manager.users.hhakem = {
    imports = [
      inputs.agenix.homeManagerModules.default
      ../../homes/hhakem/moby.nix
    ];
  };

  home-manager.users.zchen = {
    imports = [
      inputs.agenix.homeManagerModules.default
      ../../homes/zchen/moby.nix
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
