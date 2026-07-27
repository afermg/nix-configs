# Darwin side for Syncthing folders shared with moby.
#
# This host's existing Syncthing identity is:
# TKXRRWK-K5EDNVM-AVXZKCP-TE2M2LC-A7CYJB7-LY2G5MU-EYGHIZC-I6GMRAR
# If moby should sync to this host, its "remote" device must use that ID and
# address tcp://100.110.180.8:22000.
{ config, lib, pkgs, ... }:

let
  cfg = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin;
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
        listenAddresses = [ "tcp://100.110.180.8:22000" ];
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };
    };
  };
}
