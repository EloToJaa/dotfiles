{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.settings) email;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.postgres.pgadmin;
in {
  options.modules.homelab.postgres.pgadmin = {
    enable = lib.mkEnableOption "Enable pgadmin";
    name = lib.mkOption {
      type = lib.types.str;
      default = "pgadmin";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "pgadmin";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5050;
    };
  };
  config = lib.mkIf cfg.enable {
    services.pgadmin = {
      inherit (cfg) port;
      enable = true;
      package = pkgs.unstable.pgadmin4;
      initialEmail = email;
      initialPasswordFile = config.sops.secrets."pgadmin/password".path;
    };
    systemd.services.pgadmin.serviceConfig = {
      EnvironmentFile = config.sops.templates."${cfg.name}.env".path;
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

    sops.secrets = {
      "${cfg.name}/password" = {
        owner = cfg.name;
      };
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        CONFIG_DATABASE_URI=postgresql://${cfg.name}:${config.sops.placeholder."${cfg.name}/pgpassword"}@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}
      '';
      owner = cfg.name;
    };
  };
}
