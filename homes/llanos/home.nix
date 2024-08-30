{ outputs, ... }:
{
  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
  };

  home.username = "llanos";
  home.homeDirectory = "/home/llanos";

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
