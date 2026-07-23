{ pkgs, inputs }:
with pkgs;
let
  shared-packages = import ../../homes/amunoz/packages.nix { inherit pkgs inputs; };
  # shared-packages = [];
in
shared-packages
++ (import ../shared/media_server.nix { inherit pkgs; })
++ [
  aerospace
  dockutil
  google-chrome
  inkscape
  tailscale
  teams
  zoom-us
  zulu17
]
