{lib, ...}: {
  networking = {
    useDHCP = lib.mkDefault true;
  };

  settings.isServer = true;

  powerManagement.cpuFreqGovernor = "performance";
  imports = [
    ./default.nix
    # no serial ports; srvos default spawns a failing serial-getty@ttyS0
    ({options, ...}: {
      config = lib.optionalAttrs (options ? srvos) {
        srvos.boot.consoles = ["tty0"];
      };
    })
  ];

  modules = {
    base = {
      enable = true;
      nix-ld.enable = true;
      smartd.enable = lib.mkDefault true;
      bootloader.enable = true;
      initrd.enable = true;
      tailscale.enable = true;
      ssh.enable = true;
      sudo.enable = true;
    };
    shared = {
      btop.enable = true;
      catppuccin.enable = true;
      containers.enable = true;
      index.enable = true;
      nfs.enable = true;
      nh.enable = true;
      graphics.enable = true;
    };
    homelab = {
      enable = true;
      groups.enable = true;
    };
  };
}
