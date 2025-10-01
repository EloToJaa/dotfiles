{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "vaultwarden";
  domainName = "pwd";
  group = variables.homelab.groups.main;
  dataDir = "${homelab.varDataDir}${name}";
  port = 8222;
in {
  services.vaultwarden = {
    enable = true;
    package = pkgs.unstable.vaultwarden;
    dbBackend = "postgresql";
    environmentFile = config.sops.templates."${name}.env".path;
    config = {
      ROCKET_PORT = toString port;
      SIGNUPS_ALLOWED = "false";
      INVITATIONS_ALLOWED = "false";
      WEBSOCKET_ENABLED = "true";
    };
  };
  systemd.services.vaultwarden.serviceConfig = {
    Group = lib.mkForce group;
    UMask = lib.mkForce homelab.defaultUMask;
  };
  systemd.tmpfiles.rules = [
    "d ${dataDir} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  services.restic.backups.appdata-local.paths = [
    dataDir
  ];

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
  sops.templates."${name}.env" = {
    content = ''
      DATABASE_URL=postgresql://${name}:${config.sops.placeholder."${name}/pgpassword"}@127.0.0.1:5432/${name}
      ADMIN_TOKEN=${config.sops.placeholder."${name}/admintoken"}
    '';
    owner = name;
  };
}
