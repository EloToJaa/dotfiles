{lib, ...}: {
  networking = {
    useDHCP = lib.mkForce true;
  };

  settings.isServer = true;

  powerManagement.cpuFreqGovernor = "performance";
  imports = [
    ./../../nixosModules
  ];

  modules = {
    base = {
      enable = true;
      bootloader.enable = true;
      btop.enable = true;
      catppuccin.enable = true;
      docker.enable = true;
      index.enable = true;
      initrd.enable = false;
      tailscale.enable = true;
      nfs.enable = true;
      nh.enable = true;
      ssh.enable = true;
    };
    homelab = {
      enable = true;
      groups.enable = true;
    };
  };
}
