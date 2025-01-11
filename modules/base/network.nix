{host, ...}: {
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    nameservers = ["1.1.1.1" "1.0.0.1"];
  };
  services.tailscale.enable = true;
}
