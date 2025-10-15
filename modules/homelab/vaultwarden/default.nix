{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.vaultwarden;
in {
  options.modules.homelab.vaultwarden = {
    enable = lib.mkEnableOption "Enable vaultwarden";
    name = lib.mkOption {
      type = lib.types.str;
      default = "vaultwarden";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "pwd";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8222;
    };
  };
  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      package = pkgs.unstable.vaultwarden;
      dbBackend = "postgresql";
      environmentFile = config.sops.templates."${cfg.name}.env".path;
      config = {
        ROCKET_PORT = toString cfg.port;
        SIGNUPS_ALLOWED = "false";
        INVITATIONS_ALLOWED = "false";
        WEBSOCKET_ENABLED = "true";
      };
    };
    systemd.services.vaultwarden.serviceConfig = {
      Group = lib.mkForce cfg.group;
      UMask = lib.mkForce homelab.defaultUMask;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    services.restic.backups.appdata-local.paths = [
      cfg.dataDir
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

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
      "${cfg.name}/admintoken" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        DATABASE_URL=postgresql://${cfg.name}:${config.sops.placeholder."${cfg.name}/pgpassword"}@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}
        ADMIN_TOKEN=${config.sops.placeholder."${cfg.name}/admintoken"}
      '';
      owner = cfg.name;
    };
  };
}
