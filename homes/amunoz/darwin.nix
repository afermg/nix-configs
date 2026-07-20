{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./home.nix
  ];

  home.packages = pkgs.callPackage ../../modules/darwin/packages.nix { inherit inputs; };

  programs = {
    fish.enable = true;
  }
  // import ../../modules/shared/home-manager.nix { inherit config pkgs lib; };
}
