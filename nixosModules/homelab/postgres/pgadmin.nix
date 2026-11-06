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
      initialPasswordFile = config.clan.core.vars.generators.${cfg.name}.files.password.path;
    };
    systemd.services.pgadmin.serviceConfig = {
      EnvironmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
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
        password.owner = cfg.name;
        pgpassword.deploy = false;
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
        pwgen -s 32 1 | tr -d '\n' > "$out/password"
        pwgen -s 64 1 | tr -d '\n' > "$out/pgpassword"
      '';
    };
    clan.core.vars.generators."${cfg.name}-env" = {
      dependencies = [cfg.name];
      files.env.owner = cfg.name;
      script = ''
        printf 'CONFIG_DATABASE_URI=postgresql://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}\n' \
          "$(cat "$in/${cfg.name}/pgpassword")" \
          > "$out/env"
      '';
    };
  };
}
