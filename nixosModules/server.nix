{
  inputs,
  lib,
  ...
}: {
  networking = {
    useDHCP = lib.mkDefault true;
  };

  settings.isServer = true;

  powerManagement.cpuFreqGovernor = "performance";
  imports = [
    inputs.srvos.nixosModules.server
    ./default.nix
  ];

  srvos.boot.consoles = ["tty0"]; # no serial ports; srvos default spawns a failing serial-getty@ttyS0

  modules = {
    base = {
      enable = lib.mkDefault true;
      nix-ld.enable = lib.mkDefault true;
      smartd.enable = lib.mkDefault true;
      bootloader.enable = lib.mkDefault true;
      initrd.enable = lib.mkDefault true;
      tailscale.enable = lib.mkDefault true;
      ssh.enable = lib.mkDefault true;
      sudo.enable = lib.mkDefault true;
    };
    shared = {
      btop.enable = lib.mkDefault true;
      catppuccin.enable = lib.mkDefault true;
      containers.enable = lib.mkDefault true;
      index.enable = lib.mkDefault true;
      nfs.enable = lib.mkDefault true;
      nh.enable = lib.mkDefault true;
      graphics.enable = lib.mkDefault true;
    };
    homelab = {
      enable = lib.mkDefault true;
      groups.enable = lib.mkDefault true;
    };
  };
}
