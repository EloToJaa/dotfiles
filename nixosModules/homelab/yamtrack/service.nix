{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.yamtrack;
  serviceNames = ["yamtrack" "yamtrack-worker" "yamtrack-beat"];
  commonEnvironment =
    {
      CELERY_REDIS_URL = "redis+socket://${cfg.redisSocket}";
      DATA_DIR = cfg.dataDir;
      REDIS_URL = "unix://${cfg.redisSocket}";
      TZ = cfg.timezone;
      URLS = cfg.url;
      VERSION = cfg.package.version;
    }
    // lib.optionalAttrs (cfg.databaseHost != null) {
      DB_HOST = cfg.databaseHost;
      DB_NAME = cfg.databaseName;
      DB_PORT = toString cfg.databasePort;
      DB_USER = cfg.databaseUser;
    };
  commonServiceConfig = {
    User = cfg.user;
    Group = cfg.group;
    EnvironmentFile = cfg.environmentFile;
  };
in {
  options.services.yamtrack = {
    enable = lib.mkEnableOption "Yamtrack, a self-hosted media tracker";

    package = lib.mkPackageOption pkgs "yamtrack" {};

    user = lib.mkOption {
      type = lib.types.str;
      default = "yamtrack";
      description = "The user to run Yamtrack as.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "yamtrack";
      description = "The group to run Yamtrack as.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/yamtrack";
      description = "Directory used to store Yamtrack data.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Environment file containing Yamtrack secrets.";
    };

    databaseHost = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "PostgreSQL hostname, or null to use SQLite.";
    };

    databaseName = lib.mkOption {
      type = lib.types.str;
      default = "yamtrack";
      description = "PostgreSQL database name.";
    };

    databaseUser = lib.mkOption {
      type = lib.types.str;
      default = "yamtrack";
      description = "PostgreSQL user name.";
    };

    databasePort = lib.mkOption {
      type = lib.types.port;
      default = 5432;
      description = "PostgreSQL server port.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Port used by the Yamtrack web service.";
    };

    redisSocket = lib.mkOption {
      type = lib.types.path;
      default = "/run/redis-yamtrack/redis.sock";
      description = "Unix socket used to connect to Redis.";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
      description = "Timezone used by Yamtrack.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      description = "Public URL used by Yamtrack.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = {
      yamtrack-migrate = {
        description = "Yamtrack database migration";
        before = map (name: "${name}.service") serviceNames;
        environment = commonEnvironment;
        serviceConfig =
          commonServiceConfig
          // {
            Type = "oneshot";
            ExecStart = "${cfg.package}/bin/yamtrack-manage migrate --noinput";
          };
      };

      yamtrack = {
        description = "Yamtrack web service";
        wantedBy = ["multi-user.target"];
        after = ["yamtrack-migrate.service"];
        requires = ["yamtrack-migrate.service"];
        environment = commonEnvironment;
        serviceConfig =
          commonServiceConfig
          // {
            ExecStart = "${cfg.package}/bin/yamtrack-gunicorn --bind 127.0.0.1:${toString cfg.port} config.wsgi:application";
            Restart = "on-failure";
          };
      };

      yamtrack-worker = {
        description = "Yamtrack Celery worker";
        wantedBy = ["multi-user.target"];
        after = ["yamtrack-migrate.service"];
        requires = ["yamtrack-migrate.service"];
        environment = commonEnvironment;
        serviceConfig =
          commonServiceConfig
          // {
            ExecStart = "${cfg.package}/bin/yamtrack-celery worker --loglevel INFO --without-mingle --without-gossip";
            Restart = "on-failure";
          };
      };

      yamtrack-beat = {
        description = "Yamtrack Celery scheduler";
        wantedBy = ["multi-user.target"];
        after = ["yamtrack-migrate.service"];
        requires = ["yamtrack-migrate.service"];
        environment = commonEnvironment;
        serviceConfig =
          commonServiceConfig
          // {
            ExecStart = "${cfg.package}/bin/yamtrack-celery beat --loglevel INFO --pidfile=/run/${cfg.user}/celerybeat.pid";
            Restart = "on-failure";
            RuntimeDirectory = cfg.user;
          };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.user} ${cfg.group} - -"
    ];

    users.users.${cfg.user} = {
      inherit (cfg) group;
      description = "Yamtrack service user";
      home = cfg.dataDir;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = {};
  };
}
