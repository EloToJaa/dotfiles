{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
    ./../../modules/core
  ];

  # kvm/qemu doesn't use UEFI firmware mode by default.
  # so we force-override the setting here
  # and configure GRUB instead.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;

  virtualisation.vmware.guest.enable = true;
}
