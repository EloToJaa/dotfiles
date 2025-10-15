{
  variables,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.jellystat;
in {
  options.modules.homelab.jellystat = {
    enable = lib.mkEnableOption "Enable jellystat";
    name = lib.mkOption {
      type = lib.types.str;
      default = "jellystat";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "stats";
    };
    backupDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
    };
    id = lib.mkOption {
      type = lib.types.int;
      default = 377;
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.jellystat = {
      image = "ghcr.io/cyfershepard/jellystat:unstable";
      autoStart = true;
      # podman = {
      #   user = name;
      #   sdnotify = "container";
      # };
      serviceName = cfg.name;
      extraOptions = [
        # "--cgroup-manager=cgroupfs"
        "--network=host"
      ];
      environment = {
        POSTGRES_DB = cfg.name;
        POSTGRES_USER = cfg.name;
        POSTGRES_IP = "127.0.0.1";
        POSTGRES_PORT = "5432";
        TZ = variables.timezone;
      };
      environmentFiles = [config.sops.templates."${cfg.name}.env".path];
      volumes = [
        "${cfg.backupDir}:/app/backend/backup-data"
      ];
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.backupDir} 770 ${cfg.name} ${cfg.name} - -"
    ];

    services.postgresql.ensureUsers = [
      {
        inherit (cfg) name;
        ensureDBOwnership = false;
      }
    ];
    services.postgresql.ensureDatabases = [
      cfg.name
    ];
    services.postgresqlBackup.databases = [
      cfg.name
    ];
    services.restic.backups.appdata-local.paths = [
      cfg.backupDir
    ];

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    users.users.${cfg.name} = {
      uid = cfg.id;
      group = cfg.name;
      description = cfg.name;
      home = cfg.backupDir;
    };
    users.groups.${cfg.name}.gid = cfg.id;

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
      "${cfg.name}/jwtsecret" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        POSTGRES_PASSWORD=${config.sops.placeholder."${cfg.name}/pgpassword"}
        JWT_SECRET=${config.sops.placeholder."${cfg.name}/jwtsecret"}
      '';
      owner = cfg.name;
    };
  };
}
