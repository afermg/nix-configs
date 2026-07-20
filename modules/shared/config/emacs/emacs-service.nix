{ pkgs, ... }:
{
  services.emacs = {
    enable = true;
    startWithUserSession = "graphical";
    package =
      (pkgs.emacs.override {
        withImageMagick = true;
        withXwidgets = false; # https://github.com/nix-community/emacs-overlay/issues/466
      }).pkgs.withPackages
        (_epkgs: [ ]);
  };
}
