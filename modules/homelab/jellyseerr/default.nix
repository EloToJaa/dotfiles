{
  variables,
  lib,
  config,
  ...
}: let
  name = "jellyseerr";
  domainName = "request";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 5055;
in {
  services.${name} = {
    enable = true;
    port = port;
    configDir = "${homelab.dataDir}${name}";
  };
  systemd.services.${name} = {
    environment = {
      LOG_LEVEL = "info";
      DB_TYPE = "postgres";
      DB_HOST = "127.0.0.1";
      DB_PORT = "5432";
      DB_USER = name;
      DB_NAME = name;
      DB_USE_SSL = "false";
      DB_LOG_QUERIES = "false";
    };
    serviceConfig = {
      User = name;
      Group = group;
      EnvironmentFile = config.sops.templates."${name}.env".path;
      StateDirectory = lib.mkForce null;
      DynamicUser = lib.mkForce false;
      ProtectSystem = lib.mkForce "off";
      UMask = lib.mkForce homelab.defaultUMask;
    };
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
  services.postgresqlBackup.databases = [
    name
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = name;
    group = group;
  };

  sops.secrets = {
    "${name}/pgpassword" = {
      owner = name;
    };
  };
  sops.templates."${name}.env".content = ''
    DB_PASS=${config.sops.placeholder."${name}/pgpassword"}
  '';
}
