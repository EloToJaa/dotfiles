{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.settings) email;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.postgres.pgadmin;
  vars = config.clan.core.vars.generators.${cfg.name};
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
      initialPasswordFile = vars.files.password.path;
    };
    systemd.services.pgadmin.serviceConfig = {
      EnvironmentFile = vars.files.env.path;
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
        restore.stopOnRestore = ["pgadmin.service"];
      };
      users.${cfg.name} = {};
    };

    clan.core.vars.generators.${cfg.name} = {
      files = {
        password = {
          owner = cfg.name;
          secret = true;
        };
        pgpassword = {
          owner = cfg.name;
          group = "postgres";
          mode = "0440";
          secret = true;
        };
        env = {
          owner = cfg.name;
          secret = true;
        };
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
                mkdir -p "$out"
                pwgen -s 64 1 > "$out/password"
                pgpassword=$(pwgen -s 64 1)
                printf '%s
        ' "$pgpassword" > "$out/pgpassword"
                printf 'CONFIG_DATABASE_URI=postgresql://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}
        ' "$pgpassword" > "$out/env"
      '';
    };
  };
}
