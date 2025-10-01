{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "paperless";
  domainName = "docs";
  group = variables.homelab.groups.docs;
  port = 28981;
  dataDir = "${homelab.dataDir}${name}";
  mediaDir = "${homelab.dataDir}docs";
  consumptionDir = "/mnt/Documents/";
  domain = "${domainName}.${homelab.baseDomain}";
in {
  disabledModules = [
    "services/misc/paperless.nix"
  ];
  imports = [
    ./service.nix
  ];

  services.paperless = {
    inherit port dataDir mediaDir consumptionDir domain;
    enable = true;
    package = pkgs.unstable.paperless-ngx;
    # package = inputs.nixpkgs-paperless.legacyPackages.${pkgs.system}.paperless-ngx;
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
    Group = lib.mkForce group;
    UMask = lib.mkForce homelab.defaultUMask;
  };
  systemd.tmpfiles.rules = [
    "d ${dataDir} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts.${domain} = {
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
      inherit name;
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
  sops.templates."${name}.env" = {
    content = ''
      PAPERLESS_DBPASS=${config.sops.placeholder."${name}/pgpassword"}
    '';
    owner = name;
  };
}
