{
  variables,
  lib,
  config,
  ...
}: let
  name = "paperless";
  domainName = "docs";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 28981;
in {
  services.${name} = {
    enable = true;
    port = port;
    dataDir = "${homelab.dataDir}${name}";
    mediaDir = "/mnt/Data/docs/";
    user = name;
    environmentFile = config.sops.templates."${name}.env".path;
    passwordFile = config.sops.secrets."${name}/superpassword".path;
    settings = {
      PAPERLESS_DBENGINE = "postgresql";
      PAPERLESS_DBHOST = "postgres";
      PAPERLESS_DBNAME = "paperless";
      PAPERLESS_DBUSER = name;
      PAPERLESS_TIKA_ENABLED = "1";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://gotenberg:3000";
      PAPERLESS_TIKA_ENDPOINT = "http://tika:9998";
      PAPERLESS_URL = "https://${domainName}.${homelab.baseDomain}";
    };
  };
  systemd.services.${name}.serviceConfig = {
    Group = lib.mkForce group;
    UMask = lib.mkForce homelab.defaultUMask;
  };
  systemd.tmpfiles.rules = [
    "d ${homelab.dataDir}${name} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
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

  users.users.${name} = {
    isSystemUser = true;
    description = name;
    group = lib.mkForce group;
  };

  sops.secrets = {
    "${name}/pgpassword" = {
      owner = name;
    };
    "${name}/superpassword" = {
      owner = name;
    };
  };
  sops.templates."${name}.env".content = ''
    PAPERLESS_DBPASS=${config.sops.placeholder."${name}/pgpassword"}
    PAPERLESS_REDIS: redis://:${config.sops.placeholder."redis/password"}@127.0.0.1:6379
  '';
}
