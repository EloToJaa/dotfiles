{...}: {
  imports = [
    ./backup
    ./bazarr
    ./bind
    ./caddy
    ./glance
    ./grafana
    ./immich
    ./jellyfin
    ./jellyseerr
    ./karakeep
    ./paperless
    ./postgres
    ./prometheus
    ./prowlarr
    ./qbittorrent
    ./radarr
    ./radicale
    ./sonarr
    ./uptime
    ./vaultwarden
    ./wireguard
    ./firewall.nix
    ./nat.nix
  ];
}
