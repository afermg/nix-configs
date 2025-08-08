{
  inputs,
  outputs,
}:
{
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs (
      _: flake:
      let
        legacyPackages = (flake.legacyPackages or { }).${final.system} or { };
        packages = (flake.packages or { }).${final.system} or { };
      in
      if legacyPackages != { } then legacyPackages else packages
    ) inputs;
  };

  # master = final: _: let
  #   mpkgs  = import inputs.nixpkgs-master {
  #     system = final.system;
  #     config.allowUnfree = true;
  #     config.cudaSupport = true;
  #   };
  # in {
  #   master = mpkgs;
  # };

  emacs = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
      sha256 = "sha256:08pf03fzm6ks8qb0pwjssfkz2x4ymyk0wslyq3km7v2g2d95l1n9";
    }
  );
}
