{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.jellystat;
  vars = config.clan.core.vars.generators.${cfg.name};
in {
  options.modules.homelab.jellystat = {
    enable = lib.mkEnableOption "Enable jellystat";
    name = lib.mkOption {
      type = lib.types.str;
      default = "jellystat";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "stats";
    };
    backupDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
    };
  };
  imports = [./service.nix];
  config = lib.mkIf cfg.enable {
    services.jellystat = {
      enable = true;
      package = pkgs.jellystat;
      user = cfg.name;
      group = cfg.name;

      environmentFile = vars.files.env.path;

      config = {
        jsListenIp = "127.0.0.1";
        jsPort = cfg.port;
        postgresDb = cfg.name;
        postgresUser = cfg.name;
        postgresIp = "127.0.0.1";
        postgresPort = homelab.postgres.port;
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.backupDir} 770 ${cfg.name} ${cfg.name} - -"
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
        restore.stopOnRestore = ["jellystat.service"];
      };
      users.${cfg.name} = {};
    };
    clan.core.state.jellystat = {
      folders = [
        cfg.backupDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop jellystat.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start jellystat.service
      '';
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    clan.core.vars.generators.${cfg.name} = {
      files = {
        pgpassword = {
          owner = cfg.name;
          group = "postgres";
          mode = "0440";
          secret = true;
        };
        jwtsecret = {
          owner = cfg.name;
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
                jwtsecret=$(pwgen -s 64 1)
                printf '%s
        ' "$pgpassword" > "$out/pgpassword"
                printf '%s
        ' "$jwtsecret" > "$out/jwtsecret"
                {
                  printf 'POSTGRES_PASSWORD=%s
        ' "$pgpassword"
                  printf 'JWT_SECRET=%s
        ' "$jwtsecret"
                } > "$out/env"
      '';
    };
  };
}
