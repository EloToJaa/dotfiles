{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.jellystat;
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

      environmentFile = config.sops.templates."${cfg.name}.env".path;

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
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
    };

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
      "${cfg.name}/jwtsecret" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        POSTGRES_PASSWORD=${config.sops.placeholder."${cfg.name}/pgpassword"}
        JWT_SECRET=${config.sops.placeholder."${cfg.name}/jwtsecret"}
      '';
      owner = cfg.name;
    };
  };
}
