{ pkgs, config, inputs, ...}:

{

  home.packages = with pkgs; [
    awscli
    screen
    git
    tldr
    killall
];
  programs.git = {
    enable = true;
    userName = "PaulaLlanos";
    userEmail = "llanos.paula@gmail.com";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
