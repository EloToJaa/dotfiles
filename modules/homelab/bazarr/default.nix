{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.bazarr;
in {
  options.modules.homelab.bazarr = {
    enable = lib.mkEnableOption "Bazarr module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "bazarr";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "bazarr";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 6767;
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.media;
    };
  };
  config = lib.mkIf cfg.enable {
    services.bazarr = {
      inherit (cfg) group;
      enable = true;
      package = pkgs.unstable.bazarr;
      user = cfg.name;
      listenPort = cfg.port;
    };
    systemd.services.bazarr = {
      environment = {
        POSTGRES_ENABLED = "true";
        POSTGRES_HOST = "127.0.0.1";
        POSTGRES_PORT = "5432";
        POSTGRES_USERNAME = cfg.name;
        POSTGRES_DATABASE = cfg.name;
      };
      serviceConfig = {
        EnvironmentFile = config.sops.templates."${cfg.name}.env".path;
        UMask = lib.mkForce homelab.defaultUMask;
        ExecStart = lib.mkForce "${pkgs.unstable.bazarr}/bin/bazarr --config '${homelab.dataDir}${cfg.name}' --port ${toString cfg.port} --no-update True";
      };
    };
    systemd.tmpfiles.rules = [
      "d ${homelab.dataDir}${cfg.name} 750 ${cfg.name} ${cfg.group} - -"
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
        POSTGRES_PASSWORD=${config.sops.placeholder."${cfg.name}/pgpassword"}
      '';
      owner = cfg.name;
    };
  };
}
