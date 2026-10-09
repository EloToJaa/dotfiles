{
  lib,
  modulesPath,
  ...
}: {
  # The VM profile supplies GRUB; do not also enable Limine Secure Boot.
  modules.base.bootloader.enable = lib.mkForce false;
  modules.base.smartd.enable = false;

  # Opt-in QEMU/virtio VM profile; import only on virtual machines.
  imports = ["${modulesPath}/profiles/qemu-guest.nix"];

  services.qemuGuest.enable = true;
  boot.loader.grub = {
    enable = true;
    # Override for the actual boot disk; hbox follows its disko device.
    devices = lib.mkDefault ["/dev/sda"];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;
}
