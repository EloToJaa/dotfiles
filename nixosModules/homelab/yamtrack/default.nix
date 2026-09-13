{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) timezone;
  cfg = config.modules.homelab.yamtrack;
  secret = config.clan.core.vars.generators.yamtrack-secret;
  serviceNames = ["yamtrack" "yamtrack-worker" "yamtrack-beat"];
  commonEnvironment = {
    DATA_DIR = cfg.dataDir;
    REDIS_URL = "redis://127.0.0.1:${toString cfg.redisPort}";
    TZ = timezone;
    URLS = "https://${cfg.domainName}.${homelab.baseDomain}";
    VERSION = cfg.package.version;
  };
  commonServiceConfig = {
    User = cfg.name;
    Group = cfg.name;
    EnvironmentFile = secret.files.env.path;
  };
in {
  options.modules.homelab.yamtrack = {
    enable = lib.mkEnableOption "Enable Yamtrack";

    package = lib.mkPackageOption pkgs "yamtrack" {};

    name = lib.mkOption {
      type = lib.types.str;
      default = "yamtrack";
    };

    domainName = lib.mkOption {
      type = lib.types.str;
      default = "yamtrack";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
    };

    redisPort = lib.mkOption {
      type = lib.types.port;
      default = 6381;
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };

    id = lib.mkOption {
      type = lib.types.int;
      default = 380;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = {
      yamtrack-migrate = {
        description = "Yamtrack database migration";
        after = ["redis-yamtrack.service"];
        requires = ["redis-yamtrack.service"];
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
            ExecStart = "${cfg.package}/bin/yamtrack-celery beat --loglevel INFO --pidfile=/run/yamtrack/celerybeat.pid";
            Restart = "on-failure";
            RuntimeDirectory = cfg.name;
          };
      };
    };

    services.redis.servers.yamtrack = {
      enable = true;
      port = cfg.redisPort;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.name} - -"
    ];

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
        "/static/".alias = "${cfg.package}/share/yamtrack/staticfiles/";
      };
    };

    clan.core.vars.generators.yamtrack-secret = {
      files.env = {
        owner = cfg.name;
        group = cfg.name;
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
        mkdir -p "$out"
        printf 'SECRET=%s\n' "$(pwgen -s 64 1)" > "$out/env"
      '';
    };

    clan.core.state.yamtrack = {
      folders = [cfg.dataDir];
      preBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}

        systemctl stop ${lib.concatMapStringsSep " " (name: "${name}.service") serviceNames}
      '';
      postBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}

        systemctl start ${lib.concatMapStringsSep " " (name: "${name}.service") serviceNames}
      '';
    };

    users.users.${cfg.name} = {
      uid = cfg.id;
      group = cfg.name;
      description = cfg.name;
      home = cfg.dataDir;
      isSystemUser = true;
    };
    users.groups.${cfg.name}.gid = cfg.id;
  };
}
