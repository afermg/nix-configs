{ pkgs, ... }:
let user = "zchen";
    home_parent =  "home";
in
{
  # nixpkgs = {
  #   overlays = [
  #     outputs.overlays.unstable-packages
  #   ];
  # };

  home = {
      username = "zchen" ;
      homeDirectory = "/home/zchen";
      packages = pkgs.callPackage ./packages.nix {};
    
  };
 
 home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
