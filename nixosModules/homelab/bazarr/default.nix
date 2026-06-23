{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.bazarr;
  vars = config.clan.core.vars.generators.${cfg.name};
in {
  options.modules.homelab.bazarr = {
    enable = lib.mkEnableOption "Enable bazarr";
    name = lib.mkOption {
      type = lib.types.str;
      default = "bazarr";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "bazarr";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 6767;
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.media;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
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
        EnvironmentFile = vars.files.env.path;
        UMask = lib.mkForce homelab.defaultUMask;
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

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
        printf 'POSTGRES_PASSWORD=%s\n' "$pgpassword" > "$out/env"
      '';
    };
  };
}
