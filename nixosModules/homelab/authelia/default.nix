{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.authelia;
in {
  options.modules.homelab.authelia = {
    enable = lib.mkEnableOption "Enable authelia";
    name = lib.mkOption {
      type = lib.types.str;
      default = "authelia";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "auth";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9091;
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.homelab;
    };
  };
  imports = [
    ./lldap.nix
  ];
  config = lib.mkIf cfg.enable {
    services.authelia.instances.main = {
      inherit (cfg) group;
      enable = true;
      package = pkgs.unstable.authelia;
      user = cfg.name;
      secrets = {
        jwtSecretFile = config.sops.secrets."${cfg.name}/jwtsecret".path;
        sessionSecretFile = config.sops.secrets."${cfg.name}/sessionsecret".path;
        storageEncryptionKeyFile = config.sops.secrets."${cfg.name}/storageencryptionkey".path;
      };
      settings = {
        theme = "dark";
        default_2fa_method = "mobile_push";
        server = {
          address = "tcp://127.0.0.1:${toString cfg.port}/";
          endpoints = {
            enable_pprof = false;
            enable_expvars = false;
          };
        };
        log.level = "info";
        totp.issuer = homelab.mainDomain;
        ldap = {
          address = "ldap://127.0.0.1:${toString homelab.lldap.ldapPort}";
          implementation = "lldap";
        };
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
        POSTGRES_PASSWORD=${config.sops.placeholder."${cfg.name}/pgpassword"}
      '';
      owner = cfg.name;
    };
  };
}
