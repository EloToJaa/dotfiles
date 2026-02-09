{
  networking = {
    useDHCP = false;
    interfaces."enp1s0".ipv4.addresses = [
      {
        address = "192.168.0.33";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp1s0";
    };
  };

  settings.isServer = true;

  powerManagement.cpuFreqGovernor = "performance";
  modules = {
    base = {
      enable = true;
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
      backup.enable = false;
      blocky.enable = false;
      caddy.enable = true;
      groups.enable = true;
      postgres = {
        enable = true;
        pgadmin.enable = false;
      };
    };
  };
}
