{...}: {
  imports = [
    ./caddy
    ./jellyfin
    ./postgres
    # ./radarr
    ./sonarr
    ./firewall.nix
    ./user.nix
  ];
}
