{ pkgs }:
with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  # Tex is not building in macos
  pkgs.stable.nodejs_24 # To install packages using npm
  # Keep full TeX Live coverage (including moloch) without deprecated texlive.combine.
  (texliveSmall.withPackages (ps: [ ps.scheme-full ])) # TODO try to reduce footprint
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
  ghostty # Only needed to be able to share clipboard, since wezterm is not working https://github.com/wezterm/wezterm/pull/6239

  mpv # video player # failing to compile in macos
  # xclip # For the org-download package in Emacs
  # xdotool
]
