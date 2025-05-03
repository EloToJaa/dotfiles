{variables, ...}: let
  name = "postgresql";
  homelab = variables.homelab;
  port = 5432;
in {
  services.${name} = {
    enable = true;
    dataDir = "${homelab.dataDir}${name}";
    settings.port = port;
    enableTCPIP = true;
  };

  networking.firewall.allowedTCPPorts = [port];

  imports = [
    ./pgadmin.nix
  ];
}
