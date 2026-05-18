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
      btop.enable = true;
      catppuccin.enable = true;
      bootloader.enable = true;
      docker.enable = false;
      index.enable = true;
      tailscale.enable = true;
      nfs.enable = false;
      nh.enable = true;
      ssh.enable = true;
    };
    homelab = {
      enable = true;
      blocky.enable = true;
      nginx.enable = true;
      groups.enable = true;
      home-assistant.enable = true;
      jellyfin = {
        enable = true;
        openFirewall = true;
      };
      share.enable = true;
      postgres = {
        enable = true;
        pgadmin.enable = true;
      };
    };
  };
}
