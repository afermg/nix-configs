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

  # ank = final: _: let
  #   apkgs  = import inputs.nixpkgs-ank {
  #     system = final.system;
  #     config.allowUnfree = true;
  #     config.cudaSupport = true;
  #   };
  # in {
  #   ank = apkgs;
  # };

  master = final: _: let
    mpkgs  = import inputs.nixpkgs-master {
      system = final.system;
      config.allowUnfree = true;
      config.cudaSupport = true;
    };
  in {
    master = mpkgs;
  };

}
