{
  host,
  variables,
  lib,
  ...
}: let
  dns = variables.dns;
in {
  networking = {
    hostName = "${host}";
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
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
  };
}
