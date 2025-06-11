{variables, ...}: let
  name = "postgresql";
  homelab = variables.homelab;
  port = 5432;
  dataDir = "${homelab.dataDir}${name}";
in {
  services.${name} = {
    enable = true;
    dataDir = dataDir;
    settings.port = port;
    enableTCPIP = true;
  };

  networking.firewall.allowedTCPPorts = [port];

  imports = [
    ./pgadmin.nix
  ];
}
