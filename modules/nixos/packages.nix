{ pkgs }:
with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  # Tex is not building in macos
  pkgs.stable.nodejs_24 # To install packages using npm
  texliveFull # all the stuff for tex writing  # TODO try to reduce footprint
  texlivePackages.moloch
  # python311Packages.pygments # Needed for my usual Tex templates

  # office
  libreoffice-qt6
  kdePackages.okular

  # GPU
  # cudatoolkit # Necessary to show gpu in btop
  nvitop # top for gpus (prefered)
  #nvtopPackages.full # another top for gpus

  # Text and terminal utilities
  # Gnome
  gnomeExtensions.forge
  gnomeExtensions.appindicator
  lynx
  pinta # Basic image editing # nodarwin
  zoom-us # Not working for some reason
  kitty # darwin fails

  # feh # Manage wallpapers
  # xclip # For the org-download package in Emacs
  # xdotool
]
