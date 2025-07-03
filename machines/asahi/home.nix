{
  config,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "alan";
    homeDirectory = "/home/alan";
    file = {
      ".emacs.d/init.el" = {
        text = builtins.readFile ../../modules/shared/config/emacs/init.el;
      };
      ".emacs.d/config.org" = {
        text = builtins.readFile ../../modules/shared/config/emacs/config.org;
      };
      ".emacs.d/setup-font-check.el" = {
        text = builtins.readFile ../../modules/shared/config/emacs/setup-font-check.el;
      };
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = pkgs.callPackage ../../modules/shared/packages.nix {};

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Alan Munoz";
    userEmail = "afer.mg@gmail.com";
    #extraConfig = {
    # Sign all commits using ssh key
    #    commit.gpgsign = true;
    #    gpg.format = "ssh";
    #    gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    #    user.signingkey = "~/.ssh/id_ed25519.pub";
    #  };
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.magit
    ];
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
