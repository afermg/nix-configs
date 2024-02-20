
{ pkgs, ... }:
{
  systemd.user.tmpfiles.rules = [
    ''f /dev/shm/scream-ivshmem 0660 ''${USER} qemu-libvirtd -''
    ''f /dev/shm/looking-glass 0660 ''${USER} qemu-libvirtd -''
  ];

  systemd.user.services.scream-ivshmem = {
    Unit = {
      Description = "Scream IVSHMEM";
    };

    Service = {
      ExecStart = "${pkgs.scream}/bin/scream -m /dev/shm/scream-ivshmem";
      Restart = "always";
    };
    
    Install = {
      WantedBy = [ "multi-user.target" ];
      Requires = [ "pulseaudio.service" ];
    };
  };
}
