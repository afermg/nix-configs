{ pkgs }:
with pkgs; [

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

  # To support pdbpp in emacs
  autoconf
  automake

  # browser
  firefox
  # office
  libreoffice-qt6-fresh
  
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
  btop # nicer btop

  # python
  python310 # the standard python
  poetry # python package management
  # pyright
  # ruff

  # containers
  podman  # for container needs

  # writing
  texliveFull # all the stuff for tex writing  # TODO try to reduce footprint
  (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
  pandoc
  inkscape

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
  magic-wormhole # easy sharing

  # AI
  #openai-whisper-cpp
  #piper-tts

  # LSP
  nil
  yaml-language-server
  semgrep
  nodePackages.bash-language-server
  lemminx

  # docs
  pdftk
  # (gnumeric.overrideAttrs(p: { buildInputs = p.buildInputs ++ [ zlib12 ]; }))
  
  # specific needs
  haskellPackages.xml-to-json-fast
]
