# Shell for bootstrapping flake-enabled nix and other tooling
{
  pkgs ?
  # If pkgs is not defined, instanciate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [
                       (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
                       }))
                    ];},
  inputs,
  ...
}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git

      inputs.agenix.packages.${system}.default
      ssh-to-age
      gnupg
      age
    ];
  };
}
