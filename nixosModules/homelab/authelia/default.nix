{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) username;
  cfg = config.modules.homelab.authelia;
  redisServer = config.services.redis.servers.authelia;
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
        jwtSecretFile = config.clan.core.vars.generators.${cfg.name}.files.jwtsecret.path;
        sessionSecretFile = config.clan.core.vars.generators.${cfg.name}.files.sessionsecret.path;
        storageEncryptionKeyFile = config.clan.core.vars.generators.${cfg.name}.files.storageencryptionkey.path;
        oidcHmacSecretFile = config.clan.core.vars.generators.${cfg.name}.files.oidchmacsecret.path;
        oidcIssuerPrivateKeyFile = config.clan.core.vars.generators.${cfg.name}.files.oidcprivatekey.path;
      };
      environmentVariables = {
        AUTHELIA_DUO_API_SECRET_KEY_FILE = config.clan.core.vars.generators.${cfg.name}.files.duosecretkey.path;
        AUTHELIA_STORAGE_POSTGRES_PASSWORD_FILE = config.clan.core.vars.generators.${cfg.name}.files.pgpassword.path;
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.clan.core.vars.generators.${cfg.name}.files.password.path;
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.clan.core.vars.generators.${cfg.name}.files.smtppassword.path;
      };
      settings = {
        theme = "dark";
        default_2fa_method = "totp";
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
          user = "UID=${username},OU=people,DC=elotoja,DC=com";
        };
        access_control.default_policy = "two_factor";
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
          # filesystem.filename = "${homelab.varDataDir}authelia-main/notification.txt";
          smtp = {
            address = "submission://smtp.resend.com";
            username = "resend";
            sender = "Authelia <auth@${homelab.mainDomain}>";
            subject = "[Authelia] {title}";
          };
        };
        session = {
          name = "authelia_session";
          expiration = "1h";
          inactivity = "5m";
          remember_me = "1M";
          same_site = "lax";
          cookies = [
            {
              domain = homelab.mainDomain;
              authelia_url = "https://${cfg.domainName}.${homelab.mainDomain}";
              default_redirection_url = "https://${cfg.domainName}.${homelab.mainDomain}/settings";
            }
          ];
          redis.host = redisServer.unixSocket;
        };
        regulation = {
          max_retries = 3;
          find_time = "2m";
          ban_time = "5m";
        };
      };
    };
    systemd.services.authelia-main.serviceConfig = {
      SupplementaryGroups = redisServer.group;
    };

    services.nginx.virtualHosts = let
      proxyConfig = {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    in {
      "${cfg.domainName}.${homelab.baseDomain}" = proxyConfig // {useACMEHost = homelab.baseDomain;};
      "${cfg.domainName}.${homelab.mainDomain}" = proxyConfig // {useACMEHost = homelab.mainDomain;};
    };

    services.redis.servers.authelia.enable = true;

    clan.core.postgresql = {
      databases.${cfg.name} = {
        create = {
          enable = true;
          options = {
            LC_COLLATE = "C";
            LC_CTYPE = "C";
            ENCODING = "UTF8";
            OWNER = cfg.name;
            TEMPLATE = "template0";
          };
        };
        restore.stopOnRestore = ["authelia-main.service"];
      };
      users.${cfg.name} = {};
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      inherit (cfg) group;
    };

    clan.core.vars.generators.${cfg.name} = {
      runtimeInputs = [pkgs.pwgen pkgs.openssl];
      prompts = {
        duosecretkey = {
          description = "Duo API secret key for Authelia";
          type = "hidden";
          persist = true;
        };
        password = {
          description = "LDAP bind password for Authelia (must match the lldap admin password)";
          type = "hidden";
          persist = true;
        };
        smtppassword = {
          description = "SMTP (Resend) password for Authelia notifications";
          type = "hidden";
          persist = true;
        };
      };
      script = ''
        pwgen -s 64 1 | tr -d '\n' > "$out/jwtsecret"
        pwgen -s 64 1 | tr -d '\n' > "$out/sessionsecret"
        pwgen -s 64 1 | tr -d '\n' > "$out/storageencryptionkey"
        pwgen -s 64 1 | tr -d '\n' > "$out/oidchmacsecret"
        pwgen -s 32 1 | tr -d '\n' > "$out/pgpassword"
        openssl genrsa -out "$out/oidcprivatekey" 4096
      '';
      files = lib.genAttrs [
        "jwtsecret"
        "sessionsecret"
        "storageencryptionkey"
        "pgpassword"
        "duosecretkey"
        "password"
        "oidchmacsecret"
        "oidcprivatekey"
        "smtppassword"
      ] (_: {owner = cfg.name;});
    };
  };
}
