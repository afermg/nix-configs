{ config, pkgs, ... }:
let
  gptcommitKeyPath = "${config.home.homeDirectory}/.config/gptcommit/openai-api-key";
  gptcommitWithAgenixKey = pkgs.writeShellApplication {
    name = "gptcommit";
    text = ''
      key_file=${pkgs.lib.escapeShellArg gptcommitKeyPath}
      if [[ -f "$key_file" ]]; then
        GPTCOMMIT__OPENAI__API_KEY="$(<"$key_file")"
        export GPTCOMMIT__OPENAI__API_KEY
      fi
      exec ${pkgs.gptcommit}/bin/gptcommit "$@"
    '';
  };
in
{
  age.secrets.gptcommit-openai-api-key = {
    file = ../../../../secrets/gptcommit-openai-api-key.age;
    path = gptcommitKeyPath;
    mode = "600";
  };

  home.packages = [ gptcommitWithAgenixKey ];

  home.file.".config/gptcommit/config.toml".source = ./config.toml;

  # Used by `git init` for new repositories. Existing repositories can be
  # enabled with `gptcommit install` after Home Manager installs the package.
  home.file.".config/git/templates/hooks/prepare-commit-msg" = {
    source = ./prepare-commit-msg;
    executable = true;
  };

  programs.git.settings.init.templateDir = "~/.config/git/templates";
}
