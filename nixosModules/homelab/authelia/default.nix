{
  lib,
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) username;
  cfg = config.modules.homelab.authelia;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "authelia";
    port = 9091;
    domainName = "auth";
    dataDir = false;
    mainDomain = true;
    gatus = {
      name = "Authelia";
      group = "auth";
      path = "/api/health";
    };
  };
  redisServer = config.services.redis.servers.authelia;
in {
  options.modules.homelab.authelia =
    service.options
    // {
      metricsPort = lib.mkOption {
        type = lib.types.port;
        default = 9959;
        description = "Loopback port of Authelia's telemetry listener, which serves /metrics";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.main;
      };
      forwardAuth =
        service.options.forwardAuth
        // {
          url = lib.mkOption {
            type = lib.types.str;
            default =
              if cfg.enable
              then "http://127.0.0.1:${toString cfg.port}"
              else "https://${cfg.domainName}.${homelab.mainDomain}";
            defaultText = lib.literalMD "the local listener when Authelia runs on this host, otherwise the public portal";
            description = "Base URL nginx uses for forward-auth requests to Authelia";
          };
        };
      accessControlRules = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
        default = [];
        description = "Authelia access_control rules for services on this host, collected by the Authelia host. Each forward-auth service appends its own.";
      };
      hosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Other hosts whose accessControlRules this Authelia instance enforces.";
      };
    };
  imports = [
    ./lldap.nix
  ];
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      modules.homelab.prometheus.scrapeTargets = [
        {
          job_name = "authelia";
          address = "127.0.0.1:${toString cfg.metricsPort}";
        }
      ];
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
          telemetry.metrics = {
            enabled = true;
            address = "tcp://127.0.0.1:${toString cfg.metricsPort}/metrics";
          };
          log.level = "info";
          totp.issuer = homelab.mainDomain;
          authentication_backend.ldap = {
            address = "ldap://127.0.0.1:${toString homelab.lldap.ldapPort}";
            implementation = "lldap";
            base_dn = "DC=elotoja,DC=com";
            user = "UID=${username},OU=people,DC=elotoja,DC=com";
          };
          access_control = {
            default_policy = "two_factor";
            rules =
              cfg.accessControlRules
              ++ lib.concatMap (
                host: inputs.self.nixosConfigurations.${host}.config.modules.homelab.authelia.accessControlRules
              )
              cfg.hosts;
          };
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
    })
  ];
}
