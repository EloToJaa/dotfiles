{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.bazarr;
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
        EnvironmentFile = config.sops.templates."${cfg.name}.env".path;
        UMask = lib.mkForce homelab.defaultUMask;
      };
    };
    systemd.tmpfiles.rules = [
      "d ${homelab.dataDir}${cfg.name} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
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

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        POSTGRES_PASSWORD=${config.sops.placeholder."${cfg.name}/pgpassword"}
      '';
      owner = cfg.name;
    };
  };
}
