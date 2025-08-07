{
  host,
  variables,
  pkgs,
  ...
}: let
  dns = variables.dns;
in {
  networking = {
    hostName = host;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      settings.connectivity.uri = "http://nmcheck.gnome.org/check_network_status.txt";
    };
    firewall.enable = false;
    nameservers = dns;
  };
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = ["~."];
    fallbackDns = dns;
    dnsovertls = "true";
  };
  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
  };
}
