{ lib, pkgs, ... }:
{
  services.emacs = {
    enable = true;
    startWithUserSession = true;
    package =
      (pkgs.emacs.override {
        withImageMagick = true;
        withXwidgets = false; # https://github.com/nix-community/emacs-overlay/issues/466
      }).pkgs.withPackages
        (_epkgs: [ ]);
  };

  systemd.user.services.emacs = lib.mkIf pkgs.stdenv.isLinux {
    Service = {
      Restart = lib.mkForce "always";
      RestartSec = "5s";
    };
  };
}
