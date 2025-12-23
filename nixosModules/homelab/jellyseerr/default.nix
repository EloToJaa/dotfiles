{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.jellyseerr;
in {
  options.modules.homelab.jellyseerr = {
    enable = lib.mkEnableOption "Enable jellyseerr";
    name = lib.mkOption {
      type = lib.types.str;
      default = "jellyseerr";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "request";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5055;
    };
    configDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      inherit (cfg) port configDir;
      enable = true;
      package = pkgs.unstable.jellyseerr;
    };
    systemd.services.jellyseerr = {
      environment = {
        LOG_LEVEL = "info";
        DB_TYPE = "postgres";
        DB_HOST = "127.0.0.1";
        DB_PORT = "5432";
        DB_USER = cfg.name;
        DB_NAME = cfg.name;
        DB_USE_SSL = "false";
        DB_LOG_QUERIES = "false";
        HOST = "127.0.0.1";
      };
      serviceConfig = {
        User = cfg.name;
        Group = cfg.group;
        EnvironmentFile = config.sops.templates."${cfg.name}.env".path;
        StateDirectory = lib.mkForce null;
        DynamicUser = lib.mkForce false;
        ProtectSystem = lib.mkForce "off";
        UMask = lib.mkForce homelab.defaultUMask;
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

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
      cfg.configDir
    ];

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      inherit (cfg) group;
    };

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        DB_PASS=${config.sops.placeholder."${cfg.name}/pgpassword"}
      '';
      owner = cfg.name;
    };
  };
}
