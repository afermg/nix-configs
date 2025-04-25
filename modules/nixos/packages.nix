{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  
  # browser
  firefox
  
  # office
  # libreoffice-qt6

  # GPU
  cudatoolkit # Necessary to show gpu in btop
  nvitop # top for gpus (prefered)
  nvtopPackages.full # another top for gpus
  # pkgs.unstable.ollama

  # Text and terminal utilities
  # Gnome
  gnomeExtensions.forge
  gnomeExtensions.appindicator
  # feh # Manage wallpapers
  # xclip # For the org-download package in Emacs
  # xdotool
]
