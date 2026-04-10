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
  # Programming
  mawk
  duckdb
  python314
  uv
  racket

  # Development
  git
  git-lfs
  gh
  devenv

  # Server stuff
  http-server
  shiori # download whole html websites

  # Utils
  pigz # threaded gunzip

  # Benchmark
  gprof2dot

  # Graphics processing
  graphviz

  ## AI
  opencode
  gemini-cli
  claude-code
  claude-agent-acp
  #openai-whisper-cpp
  #piper-tts

  ## docs
  pdftk
  gnumeric
  ltex-ls # language tool LSP for latex and org-mode
  autotools-language-server

  ## Linting/Formatting/LSP
  dprint # yaml,md,json
  ruff # Python
  nixfmt # ruff

  # Music
  ncspot

  ## very specific needs
  haskellPackages.xml-to-json-fast
  qrtool # encode and decode qr codes
  zotero
  nix-output-monitor

  # packages under examination
  luajitPackages.fennel # lua in fennel
  xclip # clipboard manipulation tool

]
++ shared-packages
# Linux-only packages
++ pkgs.lib.optionals pkgs.stdenv.isLinux [
]
