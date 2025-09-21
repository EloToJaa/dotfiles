{
  host,
  variables,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (variables) dns username;
in {
  networking = {
    hostName = host;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      settings.connectivity.uri = "http://nmcheck.gnome.org/check_network_status.txt";
    };
    firewall.enable = lib.mkDefault false;
    nameservers = dns;
  };
  services.resolved = {
    enable = true;
    dnssec = "false";
    domains = ["~."];
    fallbackDns = dns;
    dnsovertls = "opportunistic";
  };
  services.tailscale = {
    enable = true;
    package = pkgs.tailscale;
    # Enable caddy to acquire certificates from the tailscale daemon
    # - https://tailscale.com/blog/caddy
    permitCertUid = lib.mkIf config.services.caddy.enable "caddy";
    openFirewall = true;
    useRoutingFeatures = "both";
  };
  users.users.${username}.extraGroups = [
    "networkmanager"
  ];

  # Workaround https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkIf config.networking.networkmanager.enable false;
}
