{ pkgs, config, inputs, ...}:

{

  home.packages = with pkgs; [
    tldr # useful use cases for libs
    git
    killall
    gawk
    gnused # The one and only sed
    wget # fetch stuff
    killall # kill all the processes by name
    screen # ssh in and out of a server
    nvtopPackages.full
    lsof

    python310 # the standard python
    pyright
];
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
    initExtra = ''
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
      plugins = [ "git" "gh" ];
      theme = "fino-time";
    };
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}

