{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  # Monitor GPU
  nvitop # top for gpus (prefered)
  nvtopPackages.full # another top for gpus
  # pkgs.unstable.ollama

  # Screenshot and recording tools
  flameshot

  # Text and terminal utilities
  # feh # Manage wallpapers
  # screenkey
  # tree
  # unixtools.ifconfig
  # unixtools.netstat
  # xclip # For the org-download package in Emacs
  # xorg.xwininfo # Provides a cursor to click and learn about windows
  # xorg.xrandr
  # xdotool
]
