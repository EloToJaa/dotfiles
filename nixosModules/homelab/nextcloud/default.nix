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

      # Data
      home = cfg.dataDir;
      # datadir = "/mnt/Cloud";
      database.createLocally = false;

      # Apps
      autoUpdateApps.enable = false;
      appstoreEnable = true;
      extraAppsEnable = true;
      extraApps = {
        inherit (pkgs.unstable.nextcloud32Packages.apps) calendar contacts; #mail
      };

      # Caching
      # Enable caching using redis https://nixos.wiki/wiki/Nextcloud#Caching.
      configureRedis = true;
      # https://docs.nextcloud.com/server/26/admin_manual/configuration_server/caching_configuration.html
      caching.redis = true;
      caching.apcu = false;

      # HTTP
      https = true;
      maxUploadSize = "16G";
      hostName = "nix-nextcloud";
      # webfinger = true;
      # nginx.hstsMaxAge = 31536000;
      # webfinger = true;

      # Settings
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
        maintenance_window_start = 4; # Run jobs at 4am UTC
        log_type = "file";
        loglevel = 1;
      };
      phpOptions = {
        # The OPcache interned strings buffer is nearly full with 8, bump to 16.
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

        # https://docs.nextcloud.com/server/stable/admin_manual/configuration_files/big_file_upload_configuration.html#configuring-php
        # > Output Buffering must be turned off [...] or PHP will return memory-related errors.
        output_buffering = "Off";

        "overwrite.cli.url" = "https://${domain}";
        overwriteprotocol = "https";

        # Needed to avoid corruption per https://docs.nextcloud.com/server/21/admin_manual/configuration_server/caching_configuration.html#id2
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
    };

    # This is needed to be able to run the cron job before opening the app for the first time.
    # Otherwise the cron job fails while searching for this directory.
    systemd.services.nextcloud-setup.script = ''
      mkdir -p ${cfg.dataDir}/data/appdata_$(${occ} config:system:get instanceid)/theming/global
    '';

    services.nginx.enable = true;
    services.phpfpm.pools.nextcloud.settings = {
      "listen.owner" = "nginx";
      "listen.group" = config.services.nginx.group;
    };
    users.users.nginx.extraGroups = [cfg.name];

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations = {
        "/" = {
          root = config.services.nginx.virtualHosts.${config.services.nextcloud.hostName}.root;
          extraConfig = ''
            client_max_body_size 16G;

            add_header Strict-Transport-Security "max-age=31536000" always;
            add_header Permissions-Policy "interest-cohort=()" always;
            add_header X-Content-Type-Options "nosniff" always;
            add_header X-Frame-Options "SAMEORIGIN" always;
            add_header Referrer-Policy "no-referrer" always;
            add_header X-XSS-Protection "1; mode=block" always;
            add_header X-Permitted-Cross-Domain-Policies "none" always;
            add_header X-Robots-Tag "noindex, nofollow" always;
          '';
        };

        "~ ^/remote" = {
          extraConfig = ''
            return 301 /remote.php$request_uri;
          '';
        };

        "~ ^/\\.well-known/(carddav|caldav)" = {
          extraConfig = ''
            return 301 /remote.php/dav;
          '';
        };

        "~ ^/\\.well-known" = {
          extraConfig = ''
            return 301 /index.php$request_uri;
          '';
        };

        "~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/" = {
          extraConfig = ''
            return 404;
          '';
        };

        "~ ^/(?:\\.|autotest|occ|issue|indie|db_|console)" = {
          extraConfig = ''
            return 404;
          '';
        };

        "~ \\.(?:css|js|mjs|svg|gif|png|jpg|ico|wasm|tflite)$" = {
          extraConfig = ''
            add_header Cache-Control "max-age=15778463, $http_if_modified_since";
          '';
        };

        "~ \\.woff2$" = {
          extraConfig = ''
            add_header Cache-Control "max-age=604800";
          '';
        };

        "~ \\.php(?:/|$)" = {
          extraConfig = ''
            include ${config.services.nginx.package}/conf/fastcgi.conf;
            fastcgi_split_path_info ^(.+?\.php)(/.*)$;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_param front_controller_active true;
            fastcgi_param modHeadersAvailable true;
            fastcgi_pass unix:/run/phpfpm/nextcloud.sock;
            fastcgi_read_timeout 1200;
          '';
        };
      };
    };

    # Fix for memories
    # https://memories.gallery/troubleshooting/#trigger-compatibility-mode
    systemd.services.nextcloud-cron = {
      path = [pkgs.perl];
    };

    # Ensure that postgres is running *before* running the setup
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
