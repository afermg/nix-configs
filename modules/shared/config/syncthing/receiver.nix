# Receiver side for the send-only Syncthing folder declared by moby in
# github:afermg/nix-configs?ref=feat/syncthing-sync#moby.
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
    # the moby sender and its receive-only folder.
    overrideDevices = false;
    overrideFolders = false;

    settings = {
      devices."moby" = {
        id = "KAIQMYC-65TNVPG-2AP7SH7-MZ6YKUL-QYBJ7J6-VCER24G-PJ7PBK7-L3ASMQD";
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
