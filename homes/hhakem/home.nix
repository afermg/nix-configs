{ outputs, ... }:
{
  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
  };

  home.username = "hhakem";
  home.homeDirectory = "/home/hhakem";

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
