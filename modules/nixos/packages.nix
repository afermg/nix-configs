{pkgs}:
with pkgs; let
  shared-packages = import ../shared/packages.nix {inherit pkgs;};
in
  shared-packages
  ++ [
    # Tex is not building in macos
    texliveFull # all the stuff for tex writing  # TODO try to reduce footprint
    python311Packages.pygments # Needed for my usual Tex templates
    # (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

    # office
    # libreoffice-qt6

    # GPU
    cudatoolkit # Necessary to show gpu in btop
    nvitop # top for gpus (prefered)
    #nvtopPackages.full # another top for gpus
    # pkgs.unstable.ollama # Use a service instead

    # Text and terminal utilities
    # Gnome
    gnomeExtensions.forge
    gnomeExtensions.appindicator
    # feh # Manage wallpapers
    # xclip # For the org-download package in Emacs
    # xdotool
  ]
