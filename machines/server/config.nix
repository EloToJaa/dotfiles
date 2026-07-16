{
  imports = [
    ./../../nixosModules/server.nix
  ];

  modules.homelab = {
    enable = true;
    atuin.enable = true;
    authelia.enable = true;
    lldap.enable = true;
    bazarr.enable = true;
    blocky.enable = true;
    nginx.enable = true;
    cleanuparr.enable = true;
    glance.enable = false;
    grafana.enable = true;
    hermes.enable = true;
    home-assistant.enable = true;
    immich.enable = true;
    jellyfin = {
      enable = true;
      auth.enable = true;
    };
    seerr.enable = true;
    siyuan.enable = false;
    jellystat.enable = true;
    karakeep.enable = true;
    kerberos.enable = false;
    lidarr.enable = true;
    loki.enable = true;
    mosquitto.enable = true;
    musicseerr.enable = true;
    n8n.enable = false;
    navidrome.enable = true;
    opencloud.enable = false;
    ntfy.enable = true;
    open-webui.enable = false;
    paperless.enable = true;
    postgres = {
      enable = true;
      pgadmin.enable = true;
    };
    profilarr.enable = false;
    prometheus.enable = true;
    prowlarr = {
      enable = true;
      flaresolverr.enable = true;
    };
    qbittorrent = {
      enable = true;
      vuetorrent.enable = true;
    };
    radarr.enable = true;
    rustdesk.enable = true;
    sonarr.enable = true;
    uptime.enable = true;
    vaultwarden = {
      enable = true;
      auth.enable = false;
    };
    wireguard.enable = true;
    xandikos.enable = true;
    zigbee2mqtt.enable = true;
  };
}
