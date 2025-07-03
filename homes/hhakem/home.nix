{
  config,
  pkgs,
  outputs,
  ...
}: let
  user = "hhakem";
  home_parent = "home";
in {
  # nixpkgs = {
  #   overlays = [
  #     outputs.overlays.OVERLAYNAME
  #   ];
  # };

  home = {
    username = "${user}";
    homeDirectory = "/${home_parent}/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "HugoHakem";
    userEmail = "hugo.hakem@berkeley.edu";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      ns = "nix search nixpkgs";
    };
    initContent = ''
      function nx() {
        nix-shell -p $1
      }

      bindkey '^I' complete-word
      bindkey '^[[Z' autosuggest-accept
    '';
    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "gh"];
      theme = "fino-time";
    };
  };
}
