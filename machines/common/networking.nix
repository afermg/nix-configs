{ ... }:
{
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  networking.nameservers = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"
  ];

  systemd.services.NetworkManager-wait-online.enable = false;
}
