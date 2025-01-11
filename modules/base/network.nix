{host, ...}: {
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    nameservers = ["192.168.0.31" "1.1.1.1"];
  };
  services.tailscale.enable = true;
}
