{...}: {
  imports = [
    ./backup
    ./bazarr
    ./bind
    ./caddy
    ./glance
    ./immich
    ./jellyfin
    ./jellyseerr
    ./karakeep
    ./paperless
    ./postgres
    ./prowlarr
    ./qbittorrent
    ./radarr
    ./radicale
    ./redis
    ./sonarr
    ./uptime
    ./vaultwarden
    ./wireguard
    ./firewall.nix
    ./nat.nix
  ];
}
