{
  imports = [
    ./../../nixosModules/server.nix
  ];

  modules.homelab = {
    alloy.enable = true;
    enable = true;
    ai-memory.enable = true;
    atuin.enable = true;
    authelia.enable = true;
    backup.snapshots = {
      enable = true;
      jobs = ["storagebox"];
    };
    lldap.enable = true;
    bazarr.enable = true;
    blocky.enable = true;
    nginx.enable = true;
    cleanuparr = {
      enable = true;
      auth.enable = true;
    };
    cliproxyapi.enable = true;
    forgejo.auth.enable = true;
    gatus = {
      enable = true;
      auth.enable = true;
      hosts = ["worker"];
    };
    glance = {
      enable = true;
      hosts = ["worker"];
    };
    grafana = {
      enable = true;
      auth.enable = true;
    };
    home-assistant = {
      enable = true;
      tailscaleServe.enable = true;
    };
    immich = {
      enable = true;
      auth.enable = true;
    };
    jellyfin = {
      enable = true;
      auth.enable = true;
    };
    seerr.enable = true;
    karakeep = {
      enable = true;
      auth.enable = true;
    };
    kerberos.enable = false;
    lidarr.enable = false;
    matrix.auth.enable = true;
    loki.enable = true;
    tempo.enable = true;
    mosquitto.enable = true;
    navidrome.enable = false;
    opencloud.enable = false;
    ntfy.enable = true;
    paperless = {
      enable = true;
      auth.enable = true;
    };
    postgres = {
      enable = true;
      pgadmin = {
        enable = true;
        auth.enable = true;
      };
    };
    prometheus = {
      enable = true;
      alerting = {
        enable = true;
        hosts = ["server" "worker"];
      };
    };
    prowlarr = {
      enable = true;
      flaresolverr.enable = true;
    };
    qbittorrent.enable = true;
    qui = {
      enable = true;
      auth.enable = true;
    };
    radarr = {
      enable = true;
      auth.enable = true;
    };
    rustdesk.enable = true;
    sonarr = {
      enable = true;
      auth.enable = true;
    };
    streamystats.enable = false;
    vaultwarden = {
      enable = true;
      auth.enable = true;
    };
    wireguard.enable = true;
    xandikos.enable = true;
    yamtrack = {
      enable = true;
      auth.enable = true;
    };
    zigbee2mqtt.enable = true;
  };
}
