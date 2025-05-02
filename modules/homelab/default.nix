{...}: {
  imports = [
    ./caddy
    ./jellyfin
    ./sonarr
    ./firewall.nix
    ./user.nix
  ];
}
