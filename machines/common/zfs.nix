{config, ...}: {
  boot.kernelParams = ["nohibernate"];
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      {
        devices = ["nodev"];
        path = "/boot";
      }
    ];
  };
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  services.nfs.server.enable = true;
}
