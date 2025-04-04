{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  hello
  
  # base
  coreutils
  gawk
  gnumake # Necessary for emacs' vterm
  libtool # Necessary for emacs' vterm
  gnused # The one and only sed
  parallel 
  wget # fetch stuff
  ps # processes
  killall # kill all the processes by name
  screen # ssh in and out of a server
  lsof # Files and their processes
  # git
  ripgrep # faster grep in rust
  
  # Nix
  home-manager
  
  # browser
  firefox
  
  # office
  # libreoffice-qt6

  # GPU
  nvitop # top for gpus (prefered)
  nvtopPackages.full # another top for gpus
  # pkgs.unstable.ollama

  # Text and terminal utilities
  # Gnome
  gnomeExtensions.forge
  gnomeExtensions.appindicator
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
