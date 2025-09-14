{
  variables,
  config,
  ...
}: let
  inherit (variables) homelab;
  name = "jellystat";
  domainName = "stats";
  backupDir = "${homelab.varDataDir}${name}/${name}";
  port = 3003;
in {
  virtualisation.oci-containers.containers.${name} = {
    image = "ghcr.io/cyfershepard/jellystat:unstable";
    autoStart = true;
    ports = ["${toString port}:3000"];
    podman.user = name;
    serviceName = name;
    extraOptions = ["--cgroup-manager=cgroupfs"];
    environment = {
      POSTGRES_DB = name;
      POSTGRES_USER = name;
      POSTGRES_PASSWORD = "\${POSTGRES_PASSWORD}";
      POSTGRES_IP = "127.0.0.1";
      POSTGRES_PORT = "5432";
      JWT_SECRET = "\${JWT_SECRET}";
      TZ = variables.timezone;
    };
    environmentFiles = [config.sops.templates."${name}.env".path];
    volumes = [
      "${backupDir}:/app/backend/backup-data"
    ];
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
    backupDir
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  users.users.${name} = {
    uid = 377;
    group = name;
    description = name;
    home = "/var/lib/${name}";
    autoSubUidGidRange = true;
    # linger = true;
  };
  users.groups.${name}.gid = 377;

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
