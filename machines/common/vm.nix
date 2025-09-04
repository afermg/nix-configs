{
  ...
}:
{

  virtualisation.vmVariantWithDisko = {
    #virtualisation.qemu.consoles = [ "console=ttyS0" ];
    virtualisation.qemu.options = [ "-nographic" ];

    # For running VM on macos: https://www.tweag.io/blog/2023-02-09-nixos-vm-on-macos/
    # virtualisation.host.pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
  };
}
