{
  variables,
  config,
  ...
}: let
  inherit (variables) homelab;
  name = "jellystat";
  domainName = "stats";
  backupDir = "${homelab.varDataDir}${name}";
  port = 3000;
  id = 377;
in {
  virtualisation.oci-containers.containers.jellystat = {
    image = "ghcr.io/cyfershepard/jellystat:unstable";
    autoStart = true;
    # podman = {
    #   user = name;
    #   sdnotify = "container";
    # };
    serviceName = name;
    extraOptions = [
      # "--cgroup-manager=cgroupfs"
      "--network=host"
    ];
    environment = {
      POSTGRES_DB = name;
      POSTGRES_USER = name;
      POSTGRES_IP = "127.0.0.1";
      POSTGRES_PORT = "5432";
      TZ = variables.timezone;
    };
    environmentFiles = [config.sops.templates."${name}.env".path];
    volumes = [
      "${backupDir}:/app/backend/backup-data"
    ];
  };
  systemd.tmpfiles.rules = [
    "d ${backupDir} 770 ${name} ${name} - -"
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
  services.restic.backups.appdata-local.paths = [
    backupDir
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  users.users.${name} = {
    uid = id;
    group = name;
    description = name;
    home = backupDir;
  };
  users.groups.${name}.gid = id;

  sops.secrets = {
    "${name}/pgpassword" = {
      owner = name;
    };
    "${name}/jwtsecret" = {
      owner = name;
    };
  };
  sops.templates."${name}.env" = {
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder."${name}/pgpassword"}
      JWT_SECRET=${config.sops.placeholder."${name}/jwtsecret"}
    '';
    owner = name;
  };
}
