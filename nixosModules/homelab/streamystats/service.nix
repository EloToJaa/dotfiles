{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.streamystats;
  databaseEnvironment = lib.optionalAttrs (cfg.databaseUrl != null) {
    DATABASE_URL = cfg.databaseUrl;
  };
in {
  options.services.streamystats = {
    enable = lib.mkEnableOption "Streamystats, a Jellyfin analytics platform";
    package = lib.mkPackageOption pkgs "streamystats" {};
    user = lib.mkOption {
      type = lib.types.str;
      default = "streamystats";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "streamystats";
    };
    databaseUrl = lib.mkOption {
      type = with lib.types; nullOr str;
      default = "postgresql:///streamystats?host=/run/postgresql";
      description = "PostgreSQL connection URL, or null when provided by the environment file.";
    };
    environmentFile = lib.mkOption {
      type = lib.types.path;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
    };
    jobServerPort = lib.mkOption {
      type = lib.types.port;
      default = 3005;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
      description = "Streamystats service user";
    };
    users.groups.${cfg.group} = {};

    systemd.services = {
      streamystats-migrate = {
        description = "Run Streamystats database migrations";
        after = ["postgresql.service" "streamystats-environment.service"];
        requires = ["postgresql.service" "streamystats-environment.service"];
        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${cfg.package}/bin/streamystats-migrate";
          EnvironmentFile = cfg.environmentFile;
          PrivateTmp = true;
        };
        environment =
          databaseEnvironment
          // {
            NODE_ENV = "production";
          };
      };

      streamystats-job-server = {
        description = "Streamystats background job server";
        after = ["streamystats-migrate.service"];
        requires = ["streamystats-migrate.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${cfg.package}/bin/streamystats-job-server";
          EnvironmentFile = cfg.environmentFile;
          Restart = "on-failure";
          PrivateTmp = true;
        };
        environment =
          databaseEnvironment
          // {
            HOST = "127.0.0.1";
            NODE_ENV = "production";
            PORT = toString cfg.jobServerPort;
          };
      };

      streamystats = {
        description = "Streamystats web application";
        after = ["streamystats-job-server.service"];
        requires = ["streamystats-job-server.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${cfg.package}/bin/streamystats-web";
          EnvironmentFile = cfg.environmentFile;
          Restart = "on-failure";
          PrivateTmp = true;
        };
        environment =
          databaseEnvironment
          // {
            HOSTNAME = "127.0.0.1";
            JOB_SERVER_URL = "http://127.0.0.1:${toString cfg.jobServerPort}";
            NEXT_TELEMETRY_DISABLED = "1";
            NODE_ENV = "production";
            PORT = toString cfg.port;
          };
      };
    };
  };
}
