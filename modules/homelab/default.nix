{...}: {
  imports = [
    ./bazarr
    ./caddy
    ./immich
    ./jellyfin
    ./jellyseerr
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
