# Private, one-folder Syncthing backup.
# This module is imported only by the amunoz@moby Home Manager configuration.
{ ... }:
{
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";

    # No devices or folders configured interactively may persist.
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices."remote" = {
        id = "CD7FTGY-ERFLZFS-FBW4K5L-TPW3IQ4-TZ36LIC-AUO3IGE-66LGSRI-5DTEBAG";
        addresses = [ "tcp://100.115.212.31:22000" ];
        autoAcceptFolders = false;
      };

      folders."sync" = {
        id = "sync";
        label = "Sync";
        path = "/home/amunoz/sync";
        type = "sendonly";
        devices = [ "remote" ];
        ignorePerms = true;
        fsWatcherEnabled = true;
        ignorePatterns = [ ];
      };

      # Use only the direct Tailscale path: no LAN/global discovery, NAT, or relays.
      options = {
        listenAddresses = [ "tcp://100.94.5.85:22000" ];
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };
    };
  };
}
