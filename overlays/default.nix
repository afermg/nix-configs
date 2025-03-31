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

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  unstable = final: _: let
    upkgs  = import inputs.nixpkgs-unstable {
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
      sha256="1mva57cnwj7v3k5ib1am55p0w9z539b4x05q77yqvn6bk48ca0cy";}));

}
