{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules.homelab) homelab;
  cfg = config.modules.homelab.nextcloud;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  occ = "${config.services.nextcloud.occ}/bin/nextcloud-occ";
in {
  options.modules.homelab.nextcloud = {
    enable = lib.mkEnableOption "Nextcloud module";
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
    port = lib.mkOption {
      type = lib.types.port;
      default = 3004;
    };
  };
  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      # package = pkgs.nextcloud;
      package = pkgs.unstable.nextcloud32;

      # Data
      home = cfg.dataDir;
      # datadir = "/mnt/Cloud";
      database.createLocally = false;

      # Apps
      autoUpdateApps.enable = false;
      appstoreEnable = false;
      extraAppsEnable = false;
      extraApps = {
        inherit (pkgs.nextcloud31Packages.apps) mail calendar contacts;
      };

      # Caching
      # Enable caching using redis https://nixos.wiki/wiki/Nextcloud#Caching.
      configureRedis = true;
      # https://docs.nextcloud.com/server/26/admin_manual/configuration_server/caching_configuration.html
      caching.redis = true;
      caching.apcu = false;

      # HTTP
      https = false;
      maxUploadSize = "16G";
      hostName = "nix-nextcloud";
      # webfinger = true;
      # nginx.hstsMaxAge = 31536000;
      # webfinger = true;

      # Settings
      enableImagemagick = true;
      config = {
        adminuser = variables.username;
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
        overwriteprotocol = "https";
        overwritecondaddr = "";
        overwriteport = 443;
        dbpersistent = "true";
        chunkSize = "5120MB";
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
    };

    # This is needed to be able to run the cron job before opening the app for the first time.
    # Otherwise the cron job fails while searching for this directory.
    systemd.services.nextcloud-setup.script = ''
      mkdir -p ${cfg.dataDir}/data/appdata_$(${occ} config:system:get instanceid)/theming/global
    '';

    services.nginx.virtualHosts."nix-nextcloud".listen = [
      {
        inherit (cfg) port;
        addr = "127.0.0.1";
      }
    ];

    services.nginx.enable = false;
    services.phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };
    users.users.caddy.extraGroups = ["nextcloud"];

    services.caddy.virtualHosts.${domain} = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

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
