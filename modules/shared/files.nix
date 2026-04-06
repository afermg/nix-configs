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
  ".emacs.d/config.org" = {
    text = builtins.readFile ../shared/config/emacs/config.org;
  };
}
