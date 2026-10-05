{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.srvos.nixosModules.server
    ./config.nix
    ./disko.nix
  ];

  _module.args.host = "worker";
  networking.hostName = "worker";
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  modules.shared.cpu.vendor = "intel";
  # Generic storage drivers, not a fabricated hardware report.
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
}
