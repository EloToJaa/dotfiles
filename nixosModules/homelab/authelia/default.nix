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
  vars = config.clan.core.vars.generators.${cfg.name};
  lldapVars = config.clan.core.vars.generators.${homelab.lldap.name};
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
        jwtSecretFile = vars.files.jwtsecret.path;
        sessionSecretFile = vars.files.sessionsecret.path;
        storageEncryptionKeyFile = vars.files.storageencryptionkey.path;
        oidcHmacSecretFile = vars.files.oidchmacsecret.path;
        oidcIssuerPrivateKeyFile = vars.files.oidcprivatekey.path;
      };
      environmentVariables = {
        AUTHELIA_DUO_API_SECRET_KEY_FILE = vars.files.duosecretkey.path;
        AUTHELIA_STORAGE_POSTGRES_PASSWORD_FILE = vars.files.pgpassword.path;
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = lldapVars.files.password.path;
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = vars.files.smtppassword.path;
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
      prompts = {
        duosecretkey = {
          description = "Authelia Duo API secret key";
          type = "hidden";
        };
        smtppassword = {
          description = "Authelia SMTP password";
          type = "hidden";
        };
      };
      files = {
        jwtsecret = {
          owner = cfg.name;
          secret = true;
        };
        sessionsecret = {
          owner = cfg.name;
          secret = true;
        };
        storageencryptionkey = {
          owner = cfg.name;
          secret = true;
        };
        pgpassword = {
          owner = cfg.name;
          group = "postgres";
          mode = "0440";
          secret = true;
        };
        duosecretkey = {
          owner = cfg.name;
          secret = true;
        };
        oidchmacsecret = {
          owner = cfg.name;
          secret = true;
        };
        oidcprivatekey = {
          owner = cfg.name;
          secret = true;
        };
        smtppassword = {
          owner = cfg.name;
          secret = true;
        };
        jellyfin = {
          owner = cfg.name;
          secret = true;
        };
        vaultwarden = {
          owner = cfg.name;
          secret = true;
        };
      };
      runtimeInputs = with pkgs; [
        openssl
        pwgen
      ];
      script = ''
        mkdir -p "$out"
        pwgen -s 64 1 > "$out/jwtsecret"
        pwgen -s 64 1 > "$out/sessionsecret"
        pwgen -s 64 1 > "$out/storageencryptionkey"
        pwgen -s 64 1 > "$out/pgpassword"
        cat "$prompts/duosecretkey" > "$out/duosecretkey"
        pwgen -s 64 1 > "$out/oidchmacsecret"
        openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 > "$out/oidcprivatekey"
        cat "$prompts/smtppassword" > "$out/smtppassword"
        pwgen -s 64 1 > "$out/jellyfin"
        pwgen -s 64 1 > "$out/vaultwarden"
      '';
    };
  };
}
