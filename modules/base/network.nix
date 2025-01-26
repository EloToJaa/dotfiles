{host, ...}: {
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
  };
  services.tailscale.enable = true;
}
