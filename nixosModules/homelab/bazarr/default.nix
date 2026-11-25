{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.bazarr;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "bazarr";
    port = 6767;
    glance.icon = "di:bazarr";
    gatus = {
      name = "Bazarr";
      group = "media";
      path = "/api/system/ping";
    };
    forwardAuth.bypass = ["^/api/"];
    umaskUnits = ["bazarr"];
  };
in {
  options.modules.homelab.bazarr =
    service.options
    // {
      exporterPort = lib.mkOption {
        type = lib.types.port;
        default = 9714;
        description = "Loopback port of the Exportarr instance for bazarr";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.media;
      };
    };
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      modules.homelab.prometheus.exportarr.bazarr = {
        port = cfg.exporterPort;
        url = "http://127.0.0.1:${toString cfg.port}";
        apiKeyFile = config.clan.core.vars.generators."${cfg.name}-apikey".files.apikey.path;
      };

      services.bazarr = {
        inherit (cfg) group dataDir;
        enable = true;
        package = pkgs.unstable.bazarr;
        user = cfg.name;
        listenPort = cfg.port;
      };
      systemd.services.bazarr = {
        environment = {
          POSTGRES_ENABLED = "true";
          POSTGRES_HOST = "127.0.0.1";
          POSTGRES_PORT = toString homelab.postgres.port;
          POSTGRES_USERNAME = cfg.name;
          POSTGRES_DATABASE = cfg.name;
        };
        serviceConfig = {
          EnvironmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
        };
      };
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      ];

      clan.core.state.bazarr = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop bazarr.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start bazarr.service
        '';
      };
      clan.core.postgresql = {
        databases.${cfg.name} = {
          create = {
            enable = true;
            options = {
              LC_COLLATE = "C";
              LC_CTYPE = "C";
              ENCODING = "UTF8";
              OWNER = cfg.name;
              TEMPLATE = "template0";
            };
          };
          restore.stopOnRestore = ["bazarr.service"];
        };
        users.${cfg.name} = {};
      };

      users.users.${cfg.name} = {
        inherit (cfg) group;
        isSystemUser = true;
        description = cfg.name;
      };

      clan.core.vars.generators = {
        ${cfg.name} = {
          files.pgpassword.deploy = false;
          runtimeInputs = [pkgs.pwgen];
          script = ''
            pwgen -s 64 1 > "$out/pgpassword"
          '';
        };
        "${cfg.name}-apikey" = {
          prompts.apikey = {
            description = "Bazarr API key for Exportarr (Settings > General > Security)";
            type = "hidden";
            persist = true;
          };
          files.apikey = {};
        };
        "${cfg.name}-env" = {
          dependencies = [cfg.name];
          files.env.owner = cfg.name;
          script = ''
            printf 'POSTGRES_PASSWORD=%s\n' "$(cat "$in/${cfg.name}/pgpassword")" > "$out/env"
          '';
        };
      };
    })
  ];
}
