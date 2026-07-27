# Private Syncthing folders from moby to darwin001.
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
        id = "TKXRRWK-K5EDNVM-AVXZKCP-TE2M2LC-A7CYJB7-LY2G5MU-EYGHIZC-I6GMRAR";
        addresses = [ "tcp://100.110.180.8:22000" ];
        autoAcceptFolders = false;
      };

      folders."sync" = {
        id = "sync";
        label = "Sync";
        path = "/home/amunoz/sync";
        type = "sendreceive";
        devices = [ "remote" ];
        ignorePerms = true;
        fsWatcherEnabled = true;
        ignorePatterns = [ ];
      };

      folders."private-docs-01" = {
        id = "private-docs-01";
        label = "Private Docs 01";
        path = "/home/amunoz/.local/share/syncthing/private-docs-01";
        type = "sendreceive";
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
