{ pkgs }:

with pkgs;
let 
  shared-packages = import ../../modules/shared/packages.nix { inherit pkgs; }; 
  zlib12 = (zlib.overrideAttrs(p: {
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
  shared-packages ++  [
    direnv
  ]

