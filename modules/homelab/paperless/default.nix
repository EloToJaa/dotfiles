{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  name = "paperless";
  domainName = "docs";
  homelab = variables.homelab;
  group = variables.homelab.groups.docs;
  port = 28981;
  dataDir = "${homelab.dataDir}${name}";
  mediaDir = "${homelab.dataDir}docs";
  consumptionDir = "/mnt/Documents/";
in {
  services.${name} = {
    enable = true;
    package = pkgs.unstable.paperless-ngx;
    port = port;
    dataDir = dataDir;
    mediaDir = mediaDir;
    consumptionDir = consumptionDir;
    user = name;
    environmentFile = config.sops.templates."${name}.env".path;
    settings = {
      PAPERLESS_DBENGINE = "postgresql";
      PAPERLESS_DBHOST = "127.0.0.1";
      PAPERLESS_DBNAME = "paperless";
      PAPERLESS_DBUSER = name;
      # PAPERLESS_TIKA_ENABLED = "1";
      # PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:3000";
      # PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:9998";
      PAPERLESS_URL = "https://${domainName}.${homelab.baseDomain}";
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
  systemd.services.${name}.serviceConfig = {
    Group = lib.mkForce group;
    UMask = lib.mkForce homelab.defaultUMask;
  };
  systemd.tmpfiles.rules = [
    "d ${dataDir} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      request_body {
        max_size 1000MB
      }
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  services.postgresql.ensureUsers = [
    {
      name = name;
      ensureDBOwnership = false;
    }
  ];
  services.postgresql.ensureDatabases = [
    name
  ];
  services.postgresqlBackup.databases = [
    name
  ];
  services.restic.backups.appdata-local.paths = [
    dataDir
    mediaDir
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = name;
    group = lib.mkForce group;
  };

  sops.secrets = {
    "${name}/pgpassword" = {
      owner = name;
    };
  };
  sops.templates."${name}.env".content = ''
    PAPERLESS_DBPASS=${config.sops.placeholder."${name}/pgpassword"}
  '';
}
