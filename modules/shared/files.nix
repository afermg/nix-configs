{
  pkgs,
  config,
  ...
}:
{
  # Initializes Emacs with org-mode so we can tangle the main config
  ".emacs.d/init.el" = {
    text = builtins.readFile ../shared/config/emacs/init.el;
  };
  # It is better to keep this file more flexible, for quick testing. This would prevent me from editing it.
  # ".emacs.d/config.org" = {
  #   text = builtins.readFile ../shared/config/emacs/config.org;
  # };

  # Email configuration (mbsync + msmtp)
  ".mbsyncrc" = {
    text = builtins.readFile ../shared/config/email/mbsyncrc;
  };
  ".msmtprc" = {
    text = builtins.readFile ../shared/config/email/msmtprc;
    onChange = "chmod 600 $HOME/.msmtprc";
  };
}
