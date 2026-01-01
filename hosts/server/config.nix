{
  networking = {
    useDHCP = false;
    interfaces."enp1s0".ipv4.addresses = [
      {
        address = "192.168.0.32";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp1s0";
    };
  };

  powerManagement.cpuFreqGovernor = "performance";
  imports = [
    ./../../nixosModules
  ];
  modules = {
    base = {
      enable = true;
      bootloader.enable = true;
      docker.enable = true;
      index.enable = true;
      tailscale.enable = true;
      nfs.enable = true;
      nh.enable = true;
      ssh.enable = true;
    };
    homelab = {
      enable = true;
      atuin.enable = true;
      authelia.enable = false;
      lldap.enable = true;
      backup.enable = true;
      bazarr.enable = true;
      blocky.enable = true;
      caddy.enable = true;
      cleanuparr.enable = true;
      glance.enable = false;
      grafana.enable = false;
      groups.enable = true;
      home-assistant.enable = true;
      immich.enable = true;
      jellyfin.enable = true;
      jellyseerr.enable = true;
      jellystat.enable = true;
      karakeep.enable = true;
      loki.enable = false;
      nextcloud = {
        enable = true;
        onlyoffice.enable = false;
      };
      ntfy.enable = true;
      paperless.enable = true;
      postgres = {
        enable = true;
        pgadmin.enable = true;
      };
      profilarr.enable = true;
      prometheus.enable = false;
      prowlarr = {
        enable = true;
        flaresolverr.enable = true;
      };
      qbittorrent = {
        enable = true;
        vuetorrent.enable = true;
      };
      radarr.enable = true;
      radicale.enable = true;
      rustdesk.enable = true;
      sonarr.enable = true;
      uptime.enable = true;
      vaultwarden.enable = true;
      wireguard.enable = true;
    };
  };
}
