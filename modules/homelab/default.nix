{...}: {
  imports = [
    ./firewall.nix
    ./user.nix
    ./sonarr
    ./caddy
  ];
}
