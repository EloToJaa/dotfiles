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
    ./redis
    ./sonarr
    ./vaultwarden
    # ./wireguard
    ./firewall.nix
    ./user.nix
  ];
}
