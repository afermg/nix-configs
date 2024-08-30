{ pkgs, config, inputs, ...}:
{
  home.packages = let 
    zlib12 = (pkgs.zlib.overrideAttrs(p: {
      src = let
        version ="1.2.13";
      in
        pkgs.fetchurl {
          urls = [
            "https://github.com/madler/zlib/releases/download/v${version}/zlib-${version}.tar.gz"
            "https://www.zlib.net/fossils/zlib-${version}.tar.gz"
          ];
          hash = "sha256-s6JN6XqP28g1uYMxaVAQMLiXcDG8tUs7OsE3QPhGqzA=";

        };
    }));
  in
    with pkgs; [

      # base
      gawk
      gnumake # Necessary for emacs' vterm
      libtool # Necessary for emacs' vterm
      gnused # The one and only sed
      wget # fetch stuff
      ps # processes
      killall # kill all the processes by name
      screen # ssh in and out of a server
      lsof # Files and their processes
      moreutils # e.g. sponge

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

      # files
      gnutar # The one and only tar
      rsync # sync data
      atuin # shared command history
      zip
      unzip # extract zips

      # terminals
      wezterm
      kitty
      fish
      fishPlugins.async-prompt
      fishPlugins.pure
      fishPlugins.autopair

      # fonts
      nerdfonts # nice fonts, used in doom emacs
      emacs-all-the-icons-fonts
      fontconfig # Needed for napari

      # monitor
      nvitop # top for gpus (prefered)
      nvtopPackages.full # another top for gpus
      btop # nicer btop

      # python
      python310 # the standard python
      poetry # python package management

      # containers
      podman  # for container needs

      # writing
      texliveFull # all the stuff for tex writing  # TODO try to reduce footprint
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      pandoc

      # convenience
      gnuplot # no-fuss plotting
      bc # calculator
      fzf # fuzzy finder
      jq # process json
      mermaid-cli # text to diagrams
      tldr # quick explanations

      # media
      mpv # video player
      ffmpeg # video processing needs
      imagemagick # image processing
      graphicsmagick # imagemagick (+speed, -features) alternative

      # nix
      nix-index # locate packages that provide a certain file
      nix-search-cli # find nix packages
      nixfmt-rfc-style

      # testing
      luajitPackages.fennel # lua in fennel
      monolith # download whole html websites
      xclip # clipboard manipulation tool
      magic-wormhole # easy ftp sharing

      # AI
      openai-whisper-cpp
      piper-tts
      pkgs.unstable.ollama

      # LSP
      nil
      yaml-language-server
      semgrep
      nodePackages.bash-language-server
      # pyright
      lemminx

      # docs
      pdftk
      (gnumeric.overrideAttrs(p: { buildInputs = p.buildInputs ++ [ zlib12 ]; }))

      # specific needs
      haskellPackages.xml-to-json-fast


    ];

    programs.git = {
      enable = true;
      userName = "Alan Munoz";
      userEmail = "afer.mg@gmail.com";
      #extraConfig = {
      # Sign all commits using ssh key
      #    commit.gpgsign = true;
      #    gpg.format = "ssh";
      #    gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      #    user.signingkey = "~/.ssh/id_ed25519.pub";
      #  };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    xdg = {
      enable = true;
      configFile."doom"= {
     	  source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/clouds/homes/amunoz/config/doom";
        recursive = true;
      };
      configFile."pypoetry"= {
     	  source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/clouds/homes/amunoz/config/pypoetry";
        recursive = true;
      };
      #     configFile."ipython"= {
      #   	source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/clouds/homes/amunoz/config/ipython";
      #      recursive = true;
      # };
    };
}
