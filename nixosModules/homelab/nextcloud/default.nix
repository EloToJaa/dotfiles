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
        inherit (pkgs.unstable.nextcloud31Packages.apps) mail calendar contacts onlyoffice;
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
        dbhost = "127.0.0.1:5432";
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

    services.nginx.enable = false;
    services.phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };
    users.users.caddy.extraGroups = [cfg.name];

    services.caddy.virtualHosts.${domain} = let
      virtCfg = config.services.nginx.virtualHosts."nix-nextcloud";
    in {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        encode zstd gzip

        root * ${virtCfg.root}
        root /nix-apps/* ${virtCfg.root}

        redir /.well-known/carddav /remote.php/dav 301
        redir /.well-known/caldav /remote.php/dav 301
        redir /.well-known/* /index.php{uri} 301
        redir /remote/* /remote.php{uri} 301

        header {
          Strict-Transport-Security max-age=31536000
          Permissions-Policy interest-cohort=()
          X-Content-Type-Options nosniff
          X-Frame-Options SAMEORIGIN
          Referrer-Policy no-referrer
          X-XSS-Protection "1; mode=block"
          X-Permitted-Cross-Domain-Policies none
          X-Robots-Tag "noindex, nofollow"
          -X-Powered-By
        }

        php_fastcgi unix//run/phpfpm/nextcloud.sock {
          root ${virtCfg.root}
          env front_controller_active true
          env modHeadersAvailable true
        }

        @forbidden {
          path /build/* /tests/* /config/* /lib/* /3rdparty/* /templates/* /data/*
          path /.* /autotest* /occ* /issue* /indie* /db_* /console*
          not path /.well-known/*
        }
        error @forbidden 404

        @immutable {
          path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
          query v=*
        }
        header @immutable Cache-Control "max-age=15778463, immutable"

        @static {
          path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
          not query v=*
        }
        header @static Cache-Control "max-age=15778463"

        @woff2 path *.woff2
        header @woff2 Cache-Control "max-age=604800"

        file_server
      '';
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

    services.postgresql.ensureUsers = [
      {
        inherit (cfg) name;
        ensureDBOwnership = false;
      }
    ];
    services.postgresql.ensureDatabases = [
      cfg.name
    ];
    services.postgresqlBackup.databases = [
      cfg.name
    ];
    services.restic.backups.appdata-local.paths = [
      cfg.dataDir
    ];

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
