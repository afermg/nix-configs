{
  config,
  pkgs,
  lib,
  ...
}:
let
  name = "Alán F. Muñoz";
  user = if pkgs.stdenv.isLinux then "amunoz" else "alan";
  email = "afer.mg@gmail.com";
in
{
  # Shared shell configuration

  # home.file.".ssh/allowed_signers".text = "* ${id_ed25519_pub}";
  git = {
    enable = true;
    ignores = [ "*.swp" ];
    settings.user.name = name;
    settings.user.email = email;
    lfs = {
      enable = true;
    };
    # extraConfig = {
    #   # Sign all commits using ssh key
    #   commit.gpgsign = true;
    #   gpg.format = "ssh";
    #   gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    #   user.signingkey = "~/.ssh/id_ed25519.pub";
    #   init.defaultBranch = "main";
    #   core = {
    #   editor = "emacs";
    #     autocrlf = "input";
    #   };
    #   pull.rebase = true;
    #   rebase.autoStash = true;
    # };
  };

  ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".forwardAgent = true;
    # includes = [
    #   (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
    #     "/home/${user}/.ssh/config_external"
    #   )
    #   (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
    #     "/Users/${user}/.ssh/config_external"
    #   )
    # ];
    # matchBlocks = {
    #   "github.com" = {
    #     identitiesOnly = true;
    #     identityFile = [
    #       (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
    #         "/home/${user}/.ssh/id_ed25519.pub"
    #       )
    #       (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
    #         "/Users/${user}/.ssh/id_ed25519.pub"
    #       )
    #     ];
    #   };
    # };
  };
}
