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
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
  };
  config = lib.mkIf cfg.enable {
    services.n8n = {
      enable = true;
      # package = pkgs.unstable.n8n;
      environment = {
        N8N_PORT = cfg.port;
        DB_TYPE = "postgresdb";
        DB_POSTGRESDB_DATABASE = cfg.name;
        DB_POSTGRESDB_HOST = "127.0.0.1";
        DB_POSTGRESDB_PORT = toString homelab.postgres.port;
        DB_POSTGRESDB_USER = cfg.name;
        DB_POSTGRESDB_SCHEMA = "public";
      };
    };
    systemd.services.n8n.serviceConfig = {
      EnvironmentFile = config.sops.templates."${cfg.name}.env".path;
      DynamicUser = lib.mkForce false;
      User = cfg.name;
      Group = cfg.group;
      UMask = homelab.defaultUMask;
      ExecStart = lib.mkForce "${pkgs.unstable.n8n}/bin/n8n";
    };

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    clan.core.postgresql = {
      databases.${cfg.name} = {
        create = {
          enable = true;
          options = {
            LC_COLLATE = "C";
            LC_CTYPE = "C";
            ENCODING = "UTF8";
            OWNER = cfg.name;
          };
        };
        restore.stopOnRestore = [];
      };
      users.${cfg.name} = {};
    };
    clan.core.state.n8n.folders = [
      cfg.dataDir
    ];

    users.users.${cfg.name} = {
      inherit (cfg) group;
      isSystemUser = true;
      description = cfg.name;
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
