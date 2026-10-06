{lib, ...}: {
  networking = {
    useDHCP = lib.mkDefault true;
  };

  settings.isServer = true;

  powerManagement.cpuFreqGovernor = "performance";
  imports = [
    ./default.nix
  ];

  modules = {
    base = {
      enable = true;
      nix-ld.enable = true;
      bootloader.enable = true;
      initrd.enable = false;
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
