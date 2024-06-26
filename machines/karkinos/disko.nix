{ config }:
{
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "nohibernate" ];
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "nodev"]; path = "/boot";}
    ];
  };
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  services.nfs.server.enable = true;

  disko.devices = {
    disk = {
      # SSD cluster
      ssd0 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      ssd1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
            };
          };
        };
      };
      ssd2 = {
        type = "disk";
        device = "/dev/nvme2n1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
            };
          };
        };
      };

      # HDD cluster 
      hdd0 = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zstore";
            };
            };
          };
        };
      };

      hdd1 = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zstore";
            };
            };
          };
        };
      };

      hdd2 = {
        type = "disk";
        device = "/dev/sdc";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zstore";
            };
            };
          };
        };
      };
    };
    # Z pool definitions
    zpool = {
      zroot = {
        type = "zpool";
        mode = "";
        rootFsOptions = {
          # Make sure these options are correct
          acltype = "posixacl";
          atime = "off";
          compression = "lz4";
          mountpoint = "none";
          xattr = "sa";
          "com.sun:auto-snapshot" = false;
        };
        options.ashift = "12";

        datasets = {
          "local" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options."com.sun:auto-snapshot" = true;
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = false;
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = false;
            postCreateHook = "zfs snapshot zroot/local/root@blank";
          };
        };
      };

      zstore = {
        type = "zpool";
        mode = "";
        rootFsOptions = {
          # Make sure these options are correct
          acltype = "posixacl";
          atime = "off";
          compression = "lz4";
          mountpoint = "none";
          xattr = "sa";
          "com.sun:auto-snapshot" = false;
        };
        options.ashift = "12";

        datasets = {
          datastore = {
            type = "zfs_fs";
            mountpoint = "/datastore";
            options."com.sun:auto-snapshot" = false;
            postCreateHook = "zfs snapshot zstore/datastore@blank";
          };
        };
      };
    };
  };
}