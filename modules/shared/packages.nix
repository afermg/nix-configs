{ pkgs }:
with pkgs; [
  # Essential and standard GNU
  coreutils
  gawk
  gnused # The one and only sed
  wget # fetch stuff
  ps # processes
  screen # ssh in and out of a server
  parallel # GNU parallel
  killall # kill all the processes by name
  lsof # Files and their processes

  # terminals and shells
  wezterm
  kitty
  fish
  
  # Almost essential
  git

  # Convenience
  tree
  tldr # quick explanations
  
  # files
  gnutar # The one and only tar
  rsync # sync data
  zip
  unzip # extract zips
  magic-wormhole # easy sharing


  ## faster/better X
  btop # nicer top
  ripgrep # faster grep in rust
  fd # faster find
  difftastic # better diffs
  dua # better du
  dust # interactive du in tust
  
  ## Useful when use-case shows itself
  gnuplot # no-fuss plotting
  bc # calculator
  fzf # fuzzy finder
  jq # process json
  pkgs.unstable.mermaid-cli # text to diagrams
  atuin # shared command history


  # Development
  direnv # Per-project isolated environment
  cargo # rust packages
  rustc # rust compiler
  cmake # c compiler
  clang # c language
  clang-tools # tools for c language
  libgcc # build stuff

  ## Build chains
  gnumake # Necessary for emacs' vterm
  libtool # Necessary for emacs' vterm
  autoconf
  automake
  
  ## LSP/formatters/linters
  nil # Nix
  yaml-language-server # yaml
  semgrep
  nodePackages.bash-language-server
  lemminx
  marksman #markdown
  ruff #python
  
  ## Non-LSP code helpers
  shellcheck
  shfmt
  
  # fonts
  emacs-all-the-icons-fonts
  fontconfig # Needed for napari

  # containers
  podman  # for container needs

  # writing
  texliveFull # all the stuff for tex writing  # TODO try to reduce footprint
  python311Packages.pygments # Needed for my usual Tex templates
  (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
  pandoc

  # media
  inkscape # Graphics editing
  mpv # video player
  ffmpeg # video processing needs
  imagemagick # image processing
  graphicsmagick # imagemagick (+speed, -features) alternative

  # nix utilities
  home-manager
  nix-index # locate packages that provide a certain file
  nix-search-cli # find nix packages
  nixfmt-rfc-style

]
