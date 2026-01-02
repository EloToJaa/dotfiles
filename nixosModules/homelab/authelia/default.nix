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
      default = homelab.groups.main;
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
      environmentVariables = {
        AUTHELIA_DUO_API_SECRET_KEY_FILE = config.sops.secrets."${cfg.name}/duosecretkey".path;
        AUTHELIA_STORAGE_POSTGRES_PASSWORD_FILE = config.sops.secrets."${cfg.name}/pgpassword".path;
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.sops.secrets."lldap/password".path;
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
        authentication_backend.ldap = {
          address = "ldap://127.0.0.1:${toString homelab.lldap.ldapPort}";
          implementation = "lldap";
          base_dn = "DC=elotoja,DC=com";
          user = "CN=admin,DC=elotoja,DC=com";
        };
        access_control.default_policy = "allow";
        duo_api = {
          hostname = "api-9400ee3a.duosecurity.com";
          integration_key = "DID9QW95YCI6U92UIS7Q";
          enable_self_enrollment = true;
        };
        storage.postgres = {
          address = "tcp://127.0.0.1:${toString homelab.postgres.port}";
          database = cfg.name;
          username = cfg.name;
        };
        notifier = {
          disable_startup_check = false;
          filesystem.filename = "${homelab.dataDir}authelia/notification.txt";
        };
        session = {
          name = "authelia_session";
          expiration = "1h";
          inactivity = "5m";
          remember_me = "1M";
          same_site = "lax";
          cookies = {
            inherit (config.services.authelia.instances.main.settings.session) name expiration inactivity same_site;
            domain = homelab.mainDomain;
            authelia_url = "https://${cfg.name}.${homelab.mainDomain}";
            default_redirection_url = "https://${homelab.mainDomain}";
            remember_me = "1d";
          };
          redis = {
            # host = "unix://${config.services.redis.servers.authelia.unixSocket}";
            host = config.services.redis.servers.authelia.unixSocket;
          };
        };
        security.regulation = {
          max_retries = 3;
          find_time = "2m";
          ban_time = "5m";
        };
      };
    };

    services.caddy.virtualHosts = let
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    in {
      "${cfg.domainName}.${homelab.baseDomain}" = {
        inherit extraConfig;
        useACMEHost = homelab.baseDomain;
      };
      "${cfg.domainName}.${homelab.mainDomain}" = {
        inherit extraConfig;
        useACMEHost = homelab.mainDomain;
      };
    };

    services.redis.servers.authelia.enable = true;

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
      "${cfg.name}/jwtsecret" = {
        owner = cfg.name;
      };
      "${cfg.name}/sessionsecret" = {
        owner = cfg.name;
      };
      "${cfg.name}/storageencryptionkey" = {
        owner = cfg.name;
      };
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
      "${cfg.name}/duosecretkey" = {
        owner = cfg.name;
      };
    };
  };
}
