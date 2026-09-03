{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab.postgres;
in {
  options.modules.homelab.postgres = {
    enable = lib.mkEnableOption "Enable postgres";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5432;
    };
    maxConnections = lib.mkOption {
      type = lib.types.ints.positive;
      default = 200;
      description = "Maximum number of concurrent PostgreSQL connections";
    };
  };
  imports = [
    ./pgadmin.nix
  ];
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.unstable.postgresql_18;
      settings = {
        port = cfg.port;
        max_connections = cfg.maxConnections;
      };
      enableTCPIP = true;
    };

    clan.core.postgresql.enable = true;

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
