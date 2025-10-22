{
  lib,
  config,
  ...
}: let
  inherit (config.modules.settings) username;
in {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
    ./../../modules/core
  ];

  home-manager.users.${username}.imports = [
    ./../../modules/home
    ./../../modules/desktop
  ];

  # kvm/qemu doesn't use UEFI firmware mode by default.
  # so we force-override the setting here
  # and configure GRUB instead.
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = false;
    };
  };

  virtualisation.vmware.guest.enable = true;
}
