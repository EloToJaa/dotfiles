{...}: {
  imports = [
    ./bazarr
    ./caddy
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
  ];
}
