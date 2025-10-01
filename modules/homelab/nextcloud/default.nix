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
in {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud;
    home = dataDir;
    datadir = "/mnt/Data/nextcloud";
    database.createLocally = false;
    autoUpdateApps.enable = false;
    appstoreEnable = true;
    enableImagemagick = true;
    configureRedis = true;
    caching.redis = true;
    config = {
      adminuser = variables.username;
      adminpassFile = config.sops.secrets."${name}/adminpassword".path;
      dbtype = "pgsql";
      dbhost = "127.0.0.1:5432";
      dbname = name;
      dbuser = name;
      dbpassFile = config.sops.secrets."${name}/pgpassword";
    };
    settings = {
    };
    extraApps = {
      inherit (pkgs.nextcloud31Packages.apps) mail calendar contacts;
    };
  };

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
  };
}
