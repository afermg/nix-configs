# Darwin side for Syncthing folders shared with moby.
# Moby declares both receivers; each receiver binds only its own Tailscale IP.
{ config, lib, pkgs, ... }:

let
  receiverAddresses = {
    alan = "100.72.120.59"; # darwin001 / alan-purdue-mbp
    amunozgo = "100.110.180.8"; # darwin002 / sce-bio-c06399
  };
  receiverAddress = receiverAddresses.${config.home.username} or null;
  cfg = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && receiverAddress != null);
in
cfg {
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";

    # Keep existing interactive Syncthing folders/devices intact while adding
    # the moby peer and shared folders.
    overrideDevices = false;
    overrideFolders = false;

    settings = {
      devices."moby" = {
        id = "IBGBMDU-WRH5ECV-YS3BFJ7-EPJPC5X-HVLGWGA-RUIFYSG-Y2BOQKO-MNPHHQ4";
        addresses = [ "tcp://100.94.5.85:22000" ];
        autoAcceptFolders = false;
      };

      folders."sync" = {
        id = "sync";
        label = "Sync";
        path = "${config.home.homeDirectory}/sync";
        type = "sendreceive";
        devices = [ "moby" ];
        ignorePerms = true;
        fsWatcherEnabled = true;
      };

      folders."private-docs-01" = {
        id = "private-docs-01";
        label = "Private Docs 01";
        path = "${config.home.homeDirectory}/.local/share/syncthing/private-docs-01";
        type = "sendreceive";
        devices = [ "moby" ];
        ignorePerms = true;
        fsWatcherEnabled = true;
      };

      # Match moby's direct Tailscale-only setup.
      options = {
        listenAddresses = [ "tcp://${receiverAddress}:22000" ];
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };
    };
  };
}
