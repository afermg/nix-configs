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
      sha256 = "sha256:1afshh5zhwayf17hwabqlgmr0xd7crd16npcrdcm1c4m9g36r522";
    }
  );
}
