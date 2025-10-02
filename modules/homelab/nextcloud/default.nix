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
  group = variables.homelab.groups.docs;
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
    datadir = "/mnt/Data/nextcloud";
    database.createLocally = false;

    # Apps
    autoUpdateApps.enable = false;
    appstoreEnable = true;
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
      overwritehost = "${domain}:${port}";
      trusted_domains = [domain];
      trusted_proxies = "127.0.0.1";
      overwriteprotocol = "https";
      overwritecondaddr = "";
      dbpersistent = "true";
      chunkSize = "5120MB";
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
