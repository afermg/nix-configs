{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./home.nix
  ];

  home.packages = pkgs.callPackage ../../modules/darwin/packages.nix { };

  programs = {
    fish.enable = true;
  }
  // import ../../modules/shared/home-manager.nix { inherit config pkgs lib; };
}
