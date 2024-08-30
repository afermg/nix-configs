{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    looking-glass-client
    scream
    virt-manager
    docker-compose
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
      qemu.runAsRoot = false;
      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    containers.enable = true;
    oci-containers = {
      backend = "podman";
      containers = {
        open-webui = import ./open-webui-container.nix;
      };
    };
    podman = {
      enable = true;
      enableNvidia = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.extraInit = ''
    if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
      export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
    fi
  '';

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["amd_iommu=on"];
  boot.kernelModules = ["kvm-amd"];

  # boot.initrd.availableKernelModules = [ "nvidia" "vfio-pci" ];
  # boot.initrd.preDeviceCommands = ''
  #   DEVS="0000:c1:00.0 0000:c1:00.1"
  #   for DEV in $DEVS; do
  #     echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
  #   done
  #   modprobe -i vfio-pci
  # '';

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 alan qemu-libvirtd -"
    "f /dev/shm/scream 0660 alan qemu-libvirtd -"
  ];
}
