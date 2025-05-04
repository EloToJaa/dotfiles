{...}: {
  imports = [
    ./caddy
    ./jellyfin
    ./postgres
    ./prowlarr
    ./qbittorrent
    ./radarr
    ./sonarr
    ./firewall.nix
    ./user.nix
  ];
}
