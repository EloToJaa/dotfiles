{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.paperless;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.paperless = {
    enable = lib.mkEnableOption "Enable paperless";
    name = lib.mkOption {
      type = lib.types.str;
      default = "paperless";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "docs";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.docs;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 28981;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}${cfg.name}";
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}docs";
    };
    consumptionDir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/Documents/";
    };
  };
  config = lib.mkIf cfg.enable {
    services.paperless = {
      inherit domain;
      inherit (cfg) port dataDir mediaDir consumptionDir;
      enable = true;
      package = pkgs.unstable.paperless-ngx;
      user = cfg.name;
      environmentFile = config.sops.templates."${cfg.name}.env".path;
      settings = {
        PAPERLESS_DBENGINE = "postgresql";
        PAPERLESS_DBHOST = "127.0.0.1";
        PAPERLESS_DBNAME = "paperless";
        PAPERLESS_DBUSER = cfg.name;
        # PAPERLESS_TIKA_ENABLED = "1";
        # PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:3000";
        # PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:9998";
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "pol+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };
    systemd.services.paperless.serviceConfig = {
      Group = lib.mkForce cfg.group;
      UMask = lib.mkForce homelab.defaultUMask;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.caddy.virtualHosts.${domain} = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        request_body {
          max_size 1000MB
        }
        reverse_proxy http://127.0.0.1:${toString cfg.port}
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
        restore.stopOnRestore = ["paperless-scheduler.service"];
      };
      users.${cfg.name} = {};
    };
    clan.core.state.paperless = {
      folders = [
        cfg.dataDir
        cfg.mediaDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop paperless-scheduler.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start paperless-scheduler.service
      '';
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        PAPERLESS_DBPASS=${config.sops.placeholder."${cfg.name}/pgpassword"}
      '';
      owner = cfg.name;
    };
  };
}
