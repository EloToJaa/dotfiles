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
    ./collation.nix
    ./pgadmin.nix
  ];
  config = lib.mkIf cfg.enable {
    modules.homelab.gatus.endpoints = [
      {
        name = "PostgreSQL";
        group = "infrastructure";
        url = "tcp://127.0.0.1:${toString cfg.port}";
        conditions = ["[CONNECTED] == true"];
      }
    ];

    modules.homelab.prometheus.scrapeTargets = [
      {
        job_name = "postgres";
        address = "127.0.0.1:${toString config.services.prometheus.exporters.postgres.port}";
      }
    ];

    services.prometheus.exporters.postgres = {
      enable = true;
      listenAddress = "127.0.0.1";
      runAsLocalSuperUser = true;
    };
    systemd.services.prometheus-postgres-exporter = {
      after = ["postgresql.target"];
      wants = ["postgresql.target"];
    };

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
