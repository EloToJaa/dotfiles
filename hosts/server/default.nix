{variables, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
    ./../../modules/homelab
  ];

  home-manager.users.${variables.username}.imports = [
    ./../../modules/home
  ];

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

  modules.homelab = {
    enable = true;
    atuin.enable = true;
    backup.enable = true;
    bazarr.enable = true;
    blocky.enable = true;
    caddy.enable = true;
    cleanuparr.enable = true;
    glance.enable = false;
    grafana.enable = false;
    home-assistant.enable = true;
    immich.enable = true;
    jellyfin.enable = true;
    jellyseerr.enable = true;
    jellystat.enable = true;
    karakeep.enable = true;
    loki.enable = false;
    nextcloud.enable = false;
    ntfy.enable = true;
    paperless.enable = true;
    postgres = {
      enable = true;
      pgadmin.enable = true;
    };
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
    rustdesk.enable = false;
    sonarr.enable = true;
    uptime.enable = true;
    vaultwarden.enable = true;
    wireguard.enable = true;
  };
}
