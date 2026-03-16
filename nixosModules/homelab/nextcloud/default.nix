{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.settings) username;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.nextcloud;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  occ = "${config.services.nextcloud.occ}/bin/nextcloud-occ";
in {
  options.modules.homelab.nextcloud = {
    enable = lib.mkEnableOption "Enable nextcloud";
    name = lib.mkOption {
      type = lib.types.str;
      default = "nextcloud";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "cloud";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  imports = [
    ./onlyoffice.nix
  ];
  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      package = pkgs.unstable.nextcloud32;

      home = cfg.dataDir;
      database.createLocally = false;

      autoUpdateApps.enable = false;
      appstoreEnable = true;
      extraAppsEnable = true;
      extraApps = {
        inherit (pkgs.unstable.nextcloud32Packages.apps) calendar contacts;
      };

      configureRedis = true;
      caching.redis = true;
      caching.apcu = false;

      https = true;
      maxUploadSize = "16G";
      hostName = domain;

      enableImagemagick = true;
      config = {
        adminuser = username;
        adminpassFile = config.sops.secrets."${cfg.name}/adminpassword".path;
        dbtype = "pgsql";
        dbhost = "127.0.0.1:${toString homelab.postgres.port}";
        dbname = cfg.name;
        dbuser = cfg.name;
        dbpassFile = config.sops.secrets."${cfg.name}/pgpassword".path;
      };
      settings = {
        default_phone_region = "PL";
        trusted_domains = [domain];
        trusted_proxies = ["127.0.0.1"];
        maintenance_window_start = 4;
        log_type = "file";
        loglevel = 1;
      };
      phpOptions = {
        catch_workers_output = "yes";
        display_errors = "stderr";
        error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
        expose_php = "Off";
        "opcache.enable_cli" = "1";
        "opcache.fast_shutdown" = "1";
        "opcache.interned_strings_buffer" = "16";
        "opcache.max_accelerated_files" = "10000";
        "opcache.memory_consumption" = "128";
        "opcache.revalidate_freq" = "1";
        short_open_tag = "Off";
        output_buffering = "Off";
        "overwrite.cli.url" = "https://${domain}";
        overwriteprotocol = "https";
        "redis.session.locking_enabled" = "1";
        "redis.session.lock_retries" = "-1";
        "redis.session.lock_wait_time" = "10000";
      };
      poolSettings = {
        pm = "dynamic";
        "pm.max_children" = "160";
        "pm.max_requests" = "700";
        "pm.max_spare_servers" = "120";
        "pm.min_spare_servers" = "40";
        "pm.start_servers" = "40";
      };
      nginx.hstsMaxAge = 31536000;
    };

    systemd.services.nextcloud-setup.script = ''
      mkdir -p ${cfg.dataDir}/data/appdata_$(${occ} config:system:get instanceid)/theming/global
    '';

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
    };

    systemd.services.nextcloud-cron = {
      path = [pkgs.perl];
    };

    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
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
        restore.stopOnRestore = [
          "phpfpm-nextcloud.service"
          "nextcloud-cron.timer"
        ];
      };
      users.${cfg.name} = {};
    };
    clan.core.state.nextcloud = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop phpfpm-nextcloud.service
        systemctl stop nextcloud-cron.timer
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start phpfpm-nextcloud.service
        systemctl start nextcloud-cron.timer
      '';
    };

    sops.secrets = {
      "${cfg.name}/adminpassword" = {
        owner = cfg.name;
      };
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
  };
}
