{
  host,
  variables,
  ...
}: let
  dns = variables.dns;
in {
  networking = {
    hostName = "${host}";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
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
