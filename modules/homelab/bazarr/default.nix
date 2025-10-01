{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "bazarr";
  domainName = "bazarr";
  group = variables.homelab.groups.media;
  port = 6767;
in {
  services.bazarr = {
    inherit group;
    enable = true;
    package = pkgs.unstable.bazarr;
    user = name;
    listenPort = port;
  };
  systemd.services.${name} = {
    environment = {
      POSTGRES_ENABLED = "true";
      POSTGRES_HOST = "127.0.0.1";
      POSTGRES_PORT = "5432";
      POSTGRES_USERNAME = name;
      POSTGRES_DATABASE = name;
    };
    serviceConfig = {
      EnvironmentFile = config.sops.templates."${name}.env".path;
      UMask = lib.mkForce homelab.defaultUMask;
      ExecStart = lib.mkForce "${pkgs.unstable.bazarr}/bin/bazarr --config '${homelab.dataDir}${name}' --port ${toString port} --no-update True";
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
    inherit group;
    isSystemUser = true;
    description = name;
  };

  sops.secrets = {
    "${name}/pgpassword" = {
      owner = name;
    };
  };
  sops.templates."${name}.env" = {
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder."${name}/pgpassword"}
    '';
    owner = name;
  };
}
