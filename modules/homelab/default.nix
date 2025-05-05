{...}: {
  imports = [
    ./caddy
    ./jellyfin
    ./jellyseerr
    ./postgres
    ./prowlarr
    ./qbittorrent
    ./radarr
    ./sonarr
    ./firewall.nix
    ./user.nix
  ];
}
