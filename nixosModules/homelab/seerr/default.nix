{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.seerr;
  vars = config.clan.core.vars.generators.${cfg.name};
in {
  options.modules.homelab.seerr = {
    enable = lib.mkEnableOption "Enable seerr";
    name = lib.mkOption {
      type = lib.types.str;
      default = "seerr";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "request";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5055;
    };
    configDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  # imports = [
  #   ./service.nix
  # ];
  config = lib.mkIf cfg.enable {
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
        EnvironmentFile = vars.files.env.path;
        StateDirectory = lib.mkForce null;
        DynamicUser = lib.mkForce false;
        ProtectSystem = lib.mkForce "off";
        UMask = lib.mkForce homelab.defaultUMask;
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
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

    clan.core.vars.generators.${cfg.name} = {
      files = {
        pgpassword = {
          owner = cfg.name;
          group = "postgres";
          mode = "0440";
          secret = true;
        };
        env = {
          owner = cfg.name;
          secret = true;
        };
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
        mkdir -p "$out"
        pgpassword=$(pwgen -s 64 1)
        printf '%s\n' "$pgpassword" > "$out/pgpassword"
        printf 'DB_PASS=%s\n' "$pgpassword" > "$out/env"
      '';
    };
  };
}
