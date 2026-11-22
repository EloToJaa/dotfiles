{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.gatus;
in {
  options.modules.homelab.gatus = {
    enable = lib.mkEnableOption "Enable gatus";
    name = lib.mkOption {
      type = lib.types.str;
      default = "gatus";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "status";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3011;
    };
    hosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Other hosts whose Gatus endpoints are monitored from this instance.";
    };
    endpoints = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [];
      description = "Gatus endpoints to monitor. Each homelab module appends its own.";
    };
  };
  config = lib.mkIf cfg.enable {
    services.gatus = {
      enable = true;
      environmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
      settings = {
        web = {
          address = "127.0.0.1";
          inherit (cfg) port;
        };
        storage = {
          type = "postgres";
          path = "postgres://${cfg.name}:\${GATUS_POSTGRES_PASSWORD}@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}?sslmode=disable";
        };
        endpoints =
          cfg.endpoints
          ++ lib.concatMap (
            host: inputs.self.nixosConfigurations.${host}.config.modules.homelab.gatus.endpoints
          )
          cfg.hosts;
      };
    };
    systemd.services.gatus = {
      after = ["${cfg.name}-db-password.service"];
      requires = ["${cfg.name}-db-password.service"];
    };
    systemd.services."${cfg.name}-db-password" = {
      description = "Set the ${cfg.name} PostgreSQL role password";
      after = ["postgresql.target"];
      requires = ["postgresql.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "postgres";
        LoadCredential = "env:${config.clan.core.vars.generators."${cfg.name}-env".files.env.path}";
      };
      script = ''
        . "$CREDENTIALS_DIRECTORY/env"
        printf "ALTER ROLE \"${cfg.name}\" PASSWORD '%s';\n" "$GATUS_POSTGRES_PASSWORD" \
          | ${lib.getExe' config.services.postgresql.finalPackage "psql"} --no-psqlrc --quiet --dbname=postgres
      '';
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
        restore.stopOnRestore = ["gatus.service"];
      };
      users.${cfg.name} = {};
    };

    clan.core.vars.generators = {
      ${cfg.name} = {
        files.pgpassword.deploy = false;
        runtimeInputs = [pkgs.pwgen];
        script = ''
          pwgen -s 64 1 | tr -d '\n' > "$out/pgpassword"
        '';
      };
      "${cfg.name}-env" = {
        dependencies = [cfg.name];
        files.env = {};
        script = ''
          printf 'GATUS_POSTGRES_PASSWORD=%s\n' "$(cat "$in/${cfg.name}/pgpassword")" > "$out/env"
        '';
      };
    };
  };
}
