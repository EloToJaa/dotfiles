{
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.srvos.nixosModules.server
    ../../nixosModules/vm.nix
    ./config.nix
    ./disko.nix
  ];

  _module.args.host = "hbox";
  networking.hostName = "hbox";
  nixpkgs.hostPlatform = "x86_64-linux";
  # Hetzner Cloud x86_64 VM, not Hetzner dedicated hardware.
  # Disko also contributes a GRUB device for the BIOS partition; keep one entry.
  boot.loader.grub.devices = lib.mkForce [config.disko.devices.disk.main.device];
}
