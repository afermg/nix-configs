{ inputs, ... }:
{
  imports = [
    inputs.nix-overleaf.nixosModules.overleaf
  ];

  services.overleaf = {
    enable = true;
    # Loopback only — exposed externally via SSH port forwarding for now.
    # Switch host to "0.0.0.0" + add an ACME-fronted nginx vhost to publish.
    host = "127.0.0.1";
    port = 18080;
    siteUrl = "http://localhost:18080";
    appName = "Moby Overleaf";
  };
}
