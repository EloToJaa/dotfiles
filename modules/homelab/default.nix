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
    ./firewall.nix
    ./user.nix
  ];
}
