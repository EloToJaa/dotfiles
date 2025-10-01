{
  variables,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "postgresql";
  port = 5432;
  dataDir = "${homelab.dataDir}${name}";
in {
  services.postgresql = {
    inherit dataDir;
    enable = true;
    package = pkgs.unstable.postgresql_16;
    settings.port = port;
    enableTCPIP = true;
  };

  networking.firewall.allowedTCPPorts = [port];

  imports = [
    ./pgadmin.nix
  ];
}
