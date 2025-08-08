{ pkgs }:
with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
  # shared-packages = [];
in
shared-packages
++ (import ../shared/media_server.nix { inherit pkgs; })
++ [
  dockutil
  zulu17
]
