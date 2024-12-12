{ outputs, ... }:
{
  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
  };

  home.username = "akalinin";
  home.homeDirectory = "/home/akalinin";

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
