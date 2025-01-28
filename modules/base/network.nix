{host, ...}: {
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    firewall.enable = false;
  };
  services.tailscale.enable = true;
}
