{ pkgs, config, inputs, ...}:
{
  home.packages = let 
    zlib12 = (pkgs.zlib.overrideAttrs(p: {
      src = let
        version ="1.2.13";
      in
        pkgs.fetchurl {
          urls = [
            "https://github.com/madler/zlib/releases/download/v${version}/zlib-${version}.tar.gz"
            "https://www.zlib.net/fossils/zlib-${version}.tar.gz"
          ];
          hash = "sha256-s6JN6XqP28g1uYMxaVAQMLiXcDG8tUs7OsE3QPhGqzA=";

        };
    }));
    shared-packages = import ../../modules/shared/packages.nix { inherit pkgs; };
  in
    # shared-packages
   

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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  xdg = {
    enable = true;
    configFile."doom"= {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/clouds/homes/amunoz/config/doom";
      recursive = true;
    };
    configFile."pypoetry"= {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/clouds/homes/amunoz/config/pypoetry";
      recursive = true;
    };
    #     configFile."ipython"= {
    #   	source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/clouds/homes/amunoz/config/ipython";
    #      recursive = true;
    # };
  };
}
