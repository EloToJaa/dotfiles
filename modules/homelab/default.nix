{...}: {
  imports = [
    ./bazarr
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
    ./vaultwarden
    # ./wireguard
    ./firewall.nix
    ./nat.nix
  ];
}
