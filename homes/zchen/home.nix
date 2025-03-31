{ outputs, ... }:
{
  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
  };

  home.username = "zchen" ;
  home.homeDirectory = "/home/zchen";
 
 home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
