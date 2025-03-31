{ pkgs, config, inputs, ...}:
  let shared-packages = import ../../modules/shared/packages.nix { inherit pkgs; }; in
{

  home.packages = with pkgs; [

    # To support pdbpp in emacs
    autoconf
    automake

    # faster/better X
    ripgrep # faster grep in rust
    fd # faster find
    difftastic # better diffs
    dua # better du
    dust # interactive du in rust
    bottom # network top

    # langs
    cmake # c compiler
    clang # c language
    clang-tools # tools for c language

    conda
    nvtopPackages.full # another top for gpus
] ++ shared-packages;
  programs.git = {
    enable = true;
    userName = "Zitong Chen";
    userEmail = "zchen001016@gmail.com";
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

