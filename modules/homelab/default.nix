{...}: {
  imports = [
    ./bazarr
    ./caddy
    ./jellyfin
    ./jellyseerr
    ./postgres
    ./prowlarr
    ./qbittorrent
    ./radarr
    ./sonarr
    ./vaultwarden
    ./wireguard
    ./firewall.nix
    ./user.nix
  ];
}
