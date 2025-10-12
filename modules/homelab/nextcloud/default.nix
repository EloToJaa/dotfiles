{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "nextcloud";
  domainName = "cloud";
  group = variables.homelab.groups.cloud;
  dataDir = "${homelab.varDataDir}${name}";
  domain = "${domainName}.${homelab.baseDomain}";
  port = 3004;
  occ = "${config.services.nextcloud.occ}/bin/nextcloud-occ";
in {
  services.nextcloud = {
    enable = true;
    # package = pkgs.nextcloud;

    # Data
    home = dataDir;
    datadir = "/mnt/Cloud";
    database.createLocally = false;

    # Apps
    autoUpdateApps.enable = false;
    appstoreEnable = false;
    extraAppsEnable = true;
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
    hostName = domain;
    nginx.hstsMaxAge = 31536000;
    webfinger = true;

    # Settings
    enableImagemagick = true;
    config = {
      adminuser = variables.username;
      adminpassFile = config.sops.secrets."${name}/adminpassword".path;
      dbtype = "pgsql";
      dbhost = "127.0.0.1:5432";
      dbname = name;
      dbuser = name;
      dbpassFile = config.sops.secrets."${name}/pgpassword".path;
    };
    settings = {
      default_phone_region = "PL";
      overwrite.cli.url = "https://${domain}";
      overwritehost = "${domain}:${toString port}";
      trusted_domains = [domain];
      trusted_proxies = ["127.0.0.1"];
      overwriteprotocol = "https";
      overwritecondaddr = "";
      dbpersistent = "true";
      chunkSize = "5120MB";
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
    mkdir -p ${dataDir}/data/appdata_$(${occ} config:system:get instanceid)/theming/global
  '';

  services.caddy.virtualHosts.${domain} = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  services.postgresql.ensureDatabases = [
    name
  ];
  services.postgresqlBackup.databases = [
    name
  ];
  services.restic.backups.appdata-local.paths = [
    dataDir
  ];

  users.users.${name} = {
    isSystemUser = true;
    group = lib.mkForce group;
  };

  sops.secrets = {
    "${name}/adminpassword" = {
      owner = name;
    };
    "${name}/pgpassword" = {
      owner = name;
    };
  };
}
