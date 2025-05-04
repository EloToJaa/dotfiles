{...}: {
  imports = [
    ./caddy
    ./jellyfin
    ./postgres
    ./prowlarr
    ./radarr
    ./sonarr
    ./firewall.nix
    ./user.nix
  ];
}
