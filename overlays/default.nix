{
  inputs,
  outputs,
}: {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs (
        _: flake: let
          legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
          packages = (flake.packages or {}).${final.system} or {};
        in
          if legacyPackages != {}
          then legacyPackages
          else packages
      )
      inputs;
  };

  unstable = final: _: let
    upkgs  = import inputs.nixpkgs{
      system = final.system;
      config.allowUnfree = true;
      config.cudaSupport = true;
    };
  in {
    unstable = upkgs;
  };

  master = final: _: let
    mpkgs  = import inputs.nixpkgs-master {
      system = final.system;
      config.allowUnfree = true;
      config.cudaSupport = true;
    };
  in {
    master = mpkgs;
  };

  emacs = (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
      sha256="sha256:14k4xdafdgxik6sp50f58765wz81cb792lwsxg0l4d6qqdqsihyj";}));

}
