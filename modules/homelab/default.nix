{...}: {
  imports = [
    ./caddy
    ./jellyfin
    ./postgres
    ./sonarr
    ./firewall.nix
    ./user.nix
  ];
}
