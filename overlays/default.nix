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

  # Add the stable overlay, as we are living on the edge (unstable)
  # we could replace stable with master too
  stable =
    final: _:
    let
      spkgs = import inputs.nixpkgs-stable {
        system = final.system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };
    in
    {
      stable = spkgs;
    };

  emacs = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
      sha256 = "sha256:08labbn2klkcvcz03z5b211g4jb954z3cbrzwrq6jp4c6kxa872w";
    }
  );
}
