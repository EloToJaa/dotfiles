{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.n8n;
in {
  options.modules.homelab.n8n = {
    enable = lib.mkEnableOption "Enable n8n";
    name = lib.mkOption {
      type = lib.types.str;
      default = "n8n";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "n8n";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5678;
    };
  };
  config = lib.mkIf cfg.enable {
    services.n8n = {
      enable = true;
      package = pkgs.unstable.n8n;
      environment = {
        N8N_PORT = cfg.port;
        DB_TYPE = "postgresdb";
        DB_POSTGRESDB_DATABASE = cfg.name;
        DB_POSTGRESDB_HOST = "127.0.0.1";
        DB_POSTGRESDB_PORT = toString homelab.postgres.port;
        DB_POSTGRESDB_USER = cfg.name;
        # DB_POSTGRESDB_PASSWORD = config.sops.placeholder."${cfg.name}/pgpassword";
        DB_POSTGRESDB_SCHEMA = "public";
      };
    };

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

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
      cfg.dataDir
      cfg.mediaDir
    ];

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        DB_POSTGRESDB_PASSWORD=${config.sops.placeholder."${cfg.name}/pgpassword"}
      '';
      owner = cfg.name;
    };
  };
}
