{pkgs, ...}: {
  imports = [
    ../../common/home_manager.nix
    ../../common/dev
    (import ../../common/dev/editors.nix {
      enableNvim = true;
      enableAstro = true;
    })
    (import ../../common/dev/git.nix {
      username = "Ankur Kumar";
      userEmail = "ank@leoank.me";
      id_ed25519_pub = builtins.readFile ../id_ed25519.pub;
    })
  ];

  packages = with pkgs; [
    dockutil
  ];
}