{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.seerr;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "seerr";
    port = 5055;
    domainName = "request";
    dataDir = false;
    gatus = {
      name = "Seerr";
      group = "media";
      path = "/api/v1/status";
    };
    umaskUnits = ["seerr"];
  };
in {
  options.modules.homelab.seerr =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.main;
      };
      configDir = lib.mkOption {
        type = lib.types.path;
        default = "${homelab.varDataDir}${cfg.name}";
      };
    };
  # imports = [
  #   ./service.nix
  # ];
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.seerr = {
        inherit (cfg) port configDir;
        enable = true;
        package = pkgs.unstable.seerr;
      };
      systemd.services.seerr = {
        environment = {
          LOG_LEVEL = "info";
          DB_TYPE = "postgres";
          DB_HOST = "127.0.0.1";
          DB_PORT = toString homelab.postgres.port;
          DB_USER = cfg.name;
          DB_NAME = cfg.name;
          DB_USE_SSL = "false";
          DB_LOG_QUERIES = "false";
          HOST = "127.0.0.1";
        };
        serviceConfig = {
          User = cfg.name;
          Group = cfg.group;
          EnvironmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
          StateDirectory = lib.mkForce null;
          DynamicUser = lib.mkForce false;
          ProtectSystem = lib.mkForce "off";
        };
      };
      systemd.tmpfiles.rules = [
        "d ${cfg.configDir} 750 ${cfg.name} ${cfg.group} - -"
      ];

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
          restore.stopOnRestore = ["seerr.service"];
        };
        users.${cfg.name} = {};
      };
      clan.core.state.seerr = {
        folders = [
          cfg.configDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop seerr.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start seerr.service
        '';
      };

      users.users.${cfg.name} = {
        isSystemUser = true;
        description = cfg.name;
        inherit (cfg) group;
      };

      clan.core.vars.generators = {
        ${cfg.name} = {
          files.pgpassword.deploy = false;
          runtimeInputs = [pkgs.pwgen];
          script = ''
            pwgen -s 64 1 > "$out/pgpassword"
          '';
        };
        "${cfg.name}-env" = {
          dependencies = [cfg.name];
          files.env.owner = cfg.name;
          script = ''
            printf 'DB_PASS=%s\n' "$(cat "$in/${cfg.name}/pgpassword")" > "$out/env"
          '';
        };
      };
    })
  ];
}
