{lib, ...}: {
  networking.firewall = {
    enable = lib.mkForce true;
    allowedTCPPorts = [
      22
      53
    ];
    allowedUDPPorts = [
      53
    ];
  };
}
