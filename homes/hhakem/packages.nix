{ pkgs, config, inputs, ...}:

{

  home.packages = with pkgs; [
      
    # base
    gawk
    coreutils
    gnumake # Necessary for emacs' vterm
    libtool # Necessary for emacs' vterm
    gnused # The one and only sed
    wget # fetch stuff
    ps # processes
    killall # kill all the processes by name
    screen # ssh in and out of a server
    lsof # Files and their processes
    moreutils # e.g. sponge
    btop

    # To support pdbpp in emacs
    autoconf
    automake

    # faster/better X
    ripgrep # faster grep in rust
    fd # faster find
    difftastic # better diffs
    dua # better du
    dust # interactive du in tust
    bottom # network top

    # langs
    cargo # rust packages
    rustc # rust compiler
    cmake # c compiler
    clang # c language
    clang-tools # tools for c language

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

