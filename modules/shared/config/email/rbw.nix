{ pkgs, ... }:
{
  xdg.configFile."rbw/config.json" = {
    text = builtins.toJSON {
      email = "alan@quasimorphic.com";
      sso_id = null;
      base_url = null;
      identity_url = null;
      ui_url = null;
      notifications_url = null;
      lock_timeout = 28800; # 8 hours
      sync_interval = 3600;
      pinentry = "${pkgs.pinentry-curses}/bin/pinentry-tty";
      client_cert_path = null;
    };
  };
}
