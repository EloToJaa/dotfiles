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
      default = "ldap";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 17170;
    };
  };
  config = lib.mkIf cfg.enable {
    services.lldap = {
      enable = true;
      package = pkgs.unstable.lldap;
      environmentFile = config.sops.templates."${cfg.name}.env".path;
      settings = {
        http_host = "127.0.0.1";
        http_port = cfg.port;
        http_url = "https://${cfg.domainName}.${homelab.baseDomain}";
        ldap_host = "127.0.0.1";
        ldap_port = 3890;
        ldap_base_dn = "dc=elotoja,dc=com";
        ldap_user_dn = username;
        ldap_user_email = email;
        force_ldap_user_pass_reset = "always";

        jwt_secret_file = config.sops.secrets."${cfg.name}/jwtsecret".path;
        ldap_user_pass_file = config.sops.secrets."${cfg.name}/password".path;
      };
    };
    systemd.services.lldap.serviceConfig = {
      DynamicUser = lib.mkForce false;
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
      group = lib.mkForce cfg.name;
      description = cfg.name;
    };
    users.groups.${cfg.name} = {};

    sops.secrets = {
      "${cfg.name}/jwtsecret" = {
        owner = cfg.name;
      };
      "${cfg.name}/password" = {
        owner = cfg.name;
      };
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        LLDAP_DATABASE_URL=postgres://${cfg.name}:${config.sops.placeholder."${cfg.name}/pgpassword"}@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}
      '';
      owner = cfg.name;
    };
  };
}
