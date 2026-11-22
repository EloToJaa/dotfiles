{
  imports = [
    ./../../nixosModules/server.nix
  ];

  modules.homelab = {
    enable = true;
    ai-memory.enable = true;
    atuin.enable = true;
    authelia.enable = true;
    lldap.enable = true;
    bazarr.enable = true;
    blocky.enable = true;
    nginx.enable = true;
    cleanuparr.enable = true;
    cliproxyapi.enable = true;
    gatus = {
      enable = true;
      hosts = ["worker"];
    };
    grafana.enable = true;
    home-assistant = {
      enable = true;
      tailscaleServe.enable = true;
    };
    immich.enable = true;
    jellyfin = {
      enable = true;
      auth.enable = true;
    };
    seerr.enable = true;
    karakeep.enable = true;
    kerberos.enable = false;
    lidarr.enable = false;
    loki.enable = true;
    mosquitto.enable = true;
    musicseerr.enable = false;
    navidrome.enable = false;
    opencloud.enable = false;
    ntfy.enable = true;
    paperless.enable = true;
    postgres = {
      enable = true;
      pgadmin.enable = true;
    };
    prometheus.enable = true;
    prowlarr = {
      enable = true;
      flaresolverr.enable = true;
    };
    qbittorrent.enable = true;
    qui.enable = true;
    radarr.enable = true;
    rustdesk.enable = true;
    sonarr.enable = true;
    streamystats.enable = false;
    vaultwarden = {
      enable = true;
      auth.enable = false;
    };
    wireguard.enable = true;
    xandikos.enable = true;
    yamtrack.enable = true;
    zigbee2mqtt.enable = true;
  };
}
