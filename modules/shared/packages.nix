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

  # To support pdbpp in emacs
  autoconf
  automake

  # faster/better X
  ripgrep # faster grep in rust
  fd # faster find
  difftastic # better diffs
  dua # better du
  dust # interactive du in tust

  # langs
  cargo # rust packages
  rustc # rust compiler
  cmake # c compiler
  clang # c language
  clang-tools # tools for c language
  libgcc # build stuff

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
  
  # fonts
  nerdfonts # nice fonts, used in doom emacs
  emacs-all-the-icons-fonts
  fontconfig # Needed for napari

  # monitor
  btop # nicer btop
  
  # development
  direnv
  ruff

  # containers
  podman  # for container needs

  # writing
  texliveFull # all the stuff for tex writing  # TODO try to reduce footprint
  python311Packages.pygments # Needed for my usual Tex templates
  (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
  pandoc
  inkscape

  # convenience
  gnuplot # no-fuss plotting
  bc # calculator
  fzf # fuzzy finder
  jq # process json
  pkgs.unstable.mermaid-cli # text to diagrams
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
  shiori # download whole html websites
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

  # Non-LSP code helpers
  shellcheck
  shfmt
  
  # docs
  pdftk
  # (gnumeric.overrideAttrs(p: { buildInputs = p.buildInputs ++ [ zlib12 ]; }))
  
  # specific needs
  haskellPackages.xml-to-json-fast
  direnv
  qrtool # encode and decode qr codes
]
