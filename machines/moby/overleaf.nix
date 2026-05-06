{ config, inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-overleaf.nixosModules.overleaf
  ];

  # Decrypted token containing TUNNEL_TOKEN=<...> for the cloudflared
  # tunnel that publishes overleaf.quasimorphic.com.
  age.secrets.cloudflared-overleaf = {
    file = ../../secrets/cloudflared-overleaf.age;
    owner = "cloudflared";
    group = "cloudflared";
    mode = "0400";
  };

  services.overleaf = {
    enable = true;
    # Loopback only — Cloudflare Tunnel reaches us via outbound conn.
    host = "127.0.0.1";
    port = 18080;
    # Public URL users will type in the browser. Must match what
    # Cloudflare proxies, otherwise cookies/WebSocket origin checks break.
    siteUrl = "https://overleaf.quasimorphic.com";
    appName = "Quasimorphic Overleaf";
  };

  # Cloudflare Tunnel exposes 127.0.0.1:18080 to the public internet
  # under https://overleaf.quasimorphic.com via Cloudflare's edge.
  # The tunnel + ingress mappings are managed in the Cloudflare dashboard;
  # this side just runs the connector with the token.
  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
    description = "Cloudflare Tunnel connector";
  };
  users.groups.cloudflared = { };

  systemd.services.cloudflared-overleaf = {
    description = "Cloudflare Tunnel — overleaf.quasimorphic.com";
    after = [ "network-online.target" "overleaf-web.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "notify";
      User = "cloudflared";
      Group = "cloudflared";
      EnvironmentFile = config.age.secrets.cloudflared-overleaf.path;
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared --no-autoupdate tunnel run";
      Restart = "on-failure";
      RestartSec = "5s";
      # Hardening — connector only needs outbound TCP/443 to Cloudflare.
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
    };
  };
}
