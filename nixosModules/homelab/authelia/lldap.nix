{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) username email;
  cfg = config.modules.homelab.lldap;
in {
  options.modules.homelab.lldap = {
    enable = lib.mkEnableOption "Enable lldap";
    name = lib.mkOption {
      type = lib.types.str;
      default = "lldap";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "lldap";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 17170;
    };
    ldapPort = lib.mkOption {
      type = lib.types.port;
      default = 3890;
    };
  };
  config = lib.mkIf cfg.enable {
    services.lldap = {
      enable = true;
      package = pkgs.unstable.lldap;
      environmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
      settings = {
        http_host = "127.0.0.1";
        http_port = cfg.port;
        http_url = "https://${cfg.domainName}.${homelab.baseDomain}";
        ldap_host = "127.0.0.1";
        ldap_port = cfg.ldapPort;
        ldap_base_dn = "dc=elotoja,dc=com";
        ldap_user_dn = username;
        ldap_user_email = email;
        force_ldap_user_pass_reset = "always";

        jwt_secret_file = config.clan.core.vars.generators.${cfg.name}.files.jwtsecret.path;
        ldap_user_pass_file = config.clan.core.vars.generators.${cfg.name}.files.password.path;
      };
    };
    systemd.services.lldap.serviceConfig = {
      DynamicUser = lib.mkForce false;
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
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
            TEMPLATE = "template0";
          };
        };
        restore.stopOnRestore = ["lldap.service"];
      };
      users.${cfg.name} = {};
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      group = lib.mkForce cfg.name;
      description = cfg.name;
    };
    users.groups.${cfg.name} = {};

    clan.core.vars.generators = {
      ${cfg.name} = {
        runtimeInputs = [pkgs.pwgen];
        script = ''
          pwgen -s 64 1 | tr -d '\n' > "$out/jwtsecret"
          pwgen -s 32 1 | tr -d '\n' > "$out/password"
          pwgen -s 32 1 | tr -d '\n' > "$out/pgpassword"
        '';
        files = {
          jwtsecret.owner = cfg.name;
          password.owner = cfg.name;
          pgpassword.deploy = false;
        };
      };
      "${cfg.name}-env" = {
        dependencies = [cfg.name];
        script = ''
          printf 'LLDAP_DATABASE_URL=postgres://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}\n' \
            "$(cat "$in/${cfg.name}/pgpassword")" > "$out/env"
        '';
        files.env.owner = cfg.name;
      };
    };
  };
}
