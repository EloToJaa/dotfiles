{host, ...}: {
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    firewall.enable = false;
  };
  services.resolved = {
    enable = true;
  };
  services.tailscale = {
    enable = true;
  };
}
