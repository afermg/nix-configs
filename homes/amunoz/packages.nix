# Packages that only I use
{ pkgs }:

with pkgs;
let 
  shared-packages = import ../../modules/shared/packages.nix { inherit pkgs; }; 
  # zlib12 = (zlib.overrideAttrs(p: {
  #   src = let
  #     version ="1.2.13";
  #   in
  #     pkgs.fetchurl {
  #       urls = [
  #         "https://github.com/madler/zlib/releases/download/v${version}/zlib-${version}.tar.gz"
  #         "https://www.zlib.net/fossils/zlib-${version}.tar.gz"
  #       ];
  #       hash = "sha256-s6JN6XqP28g1uYMxaVAQMLiXcDG8tUs7OsE3QPhGqzA=";

  #     };
  # }));

in 
  [
    # Terminal extensions
    fishPlugins.async-prompt
    fishPlugins.pure
    fishPlugins.autopair
    
    # Data hammers
    mawk
    duckdb
    
    # Development
    devenv
    pigz # threaded gunzip

    ## Python
    uv

    http-server
    shiori

    # Benchmark
    gprof2dot
    
    # Graphics processing
    graphviz

    # packages under examination
    luajitPackages.fennel # lua in fennel
    shiori # download whole html websites
    xclip # clipboard manipulation tool

    ## AI
    #openai-whisper-cpp
    #piper-tts

    ## docs
    pdftk
    gnumeric
    # (gnumeric.overrideAttrs(p: { buildInputs = p.buildInputs ++ [ zlib12 ]; }))
    ltex-ls # language tool LSP for latex and org-mode
    autotools-language-server
    
    ## very specific needs
    haskellPackages.xml-to-json-fast
    qrtool # encode and decode qr codes
    zotero
    nix-output-monitor
    
  ] 
  ++ shared-packages
    # Linux-only packages
  ++ pkgs.lib.optionals pkgs.stdenv.isLinux
    [
      nvtopPackages.full # another top for gpus
    ]
