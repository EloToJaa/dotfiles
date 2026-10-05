{
  lib,
  config,
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    inputs.srvos.nixosModules.server
    "${modulesPath}/profiles/qemu-guest.nix"
    ./config.nix
    ./disko.nix
  ];

  _module.args.host = "hbox";
  networking.hostName = "hbox";
  nixpkgs.hostPlatform = "x86_64-linux";
  # Hetzner Cloud x86_64 VM, not Hetzner dedicated hardware.
  services.qemuGuest.enable = true;
  boot.loader.grub = {
    enable = true;
    devices = [config.disko.devices.disk.main.device];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;
}
