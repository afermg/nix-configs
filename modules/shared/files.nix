{
  pkgs,
  config,
  ...
}:
{
  # Initializes Emacs with org-mode so we can tangle the main config.
  # `mkOutOfStoreSymlink' points the managed file at the repo path instead
  # of copying it into the read-only Nix store, so edits to init.el land
  # in the repo and take effect on the next Emacs start without a
  # home-manager rebuild. Same treatment applied across Linux and Darwin
  # (both import this file via homes/amunoz/home.nix).
  ".emacs.d/init.el" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.local/share/src/nixos-config/modules/shared/config/emacs/init.el";
  };
  # config.org is intentionally not linked here — init.el already reads it
  # directly from the repo path, so it stays editable with zero setup.

  # Email configuration (mbsync + msmtp)
  ".mbsyncrc" = {
    text = builtins.readFile ../shared/config/email/mbsyncrc;
  };
  ".msmtprc" = {
    text = builtins.readFile ../shared/config/email/msmtprc;
    onChange = "chmod 600 $HOME/.msmtprc";
  };
}
