{lib, ...}: {
  networking.firewall = {
    enable = lib.mkForce true;
    allowedTCPPorts = [
      22
    ];
  };
}
