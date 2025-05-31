{
  variables,
  lib,
  config,
  ...
}: let
  name = "vaultwarden";
  domainName = "pwd";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 8222;
in {
  services.${name} = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile = config.sops.templates."${name}.env".path;
    config = {
      ROCKET_PORT = toString port;
      SIGNUPS_ALLOWED = "true";
      INVITATIONS_ALLOWED = "false";
      WEBSOCKET_ENABLED = "true";
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
  services.postgresqlBackup.databases = [
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
    "${name}/admintoken" = {
      owner = name;
    };
  };
  sops.templates."${name}.env".content = ''
    DATABASE_URL=postgresql://${name}:${config.sops.placeholder."${name}/pgpassword"}@127.0.0.1:5432/${name}
    ADMIN_TOKEN=${config.sops.placeholder."${name}/admintoken"}
  '';
}
