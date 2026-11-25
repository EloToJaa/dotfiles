{
  config,
  lib,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.streamystats;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "streamystats";
    port = 3009;
    description = "Enable Streamystats";
    domainName = "stats";
    glance.icon = "di:streamystats";
    gatus = {
      name = "Streamystats";
      group = "media";
      path = "/api/health";
    };
  };
  environmentFile = "${cfg.dataDir}/environment";
in {
  imports = [./service.nix];

  options.modules.homelab.streamystats =
    service.options
    // {
      jobServerPort = lib.mkOption {
        type = lib.types.port;
        default = 3010;
      };
    };

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.streamystats = {
        enable = true;
        package = pkgs.streamystats;
        user = cfg.name;
        group = cfg.name;
        databaseUrl = null;
        inherit environmentFile;
        inherit (cfg) port jobServerPort;
      };

      systemd.services = {
        streamystats-environment = {
          description = "Create Streamystats runtime secrets";
          before = ["streamystats-migrate.service"];
          requiredBy = ["streamystats-migrate.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "streamystats-environment" ''
              umask 077

              if [[ ! -e ${environmentFile} ]]; then
                {
                  echo "SESSION_SECRET=$(${lib.getExe pkgs.openssl} rand -hex 64)"
                  echo "NEXT_SERVER_ACTIONS_ENCRYPTION_KEY=$(${lib.getExe pkgs.openssl} rand -base64 32)"
                } > ${environmentFile}
              fi

              if ! ${lib.getExe pkgs.gnugrep} -q '^DATABASE_URL=' ${environmentFile}; then
                database_password="$(${lib.getExe pkgs.openssl} rand -hex 32)"
                printf 'POSTGRES_PASSWORD=%s\nDATABASE_URL=postgresql://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}\n' \
                  "$database_password" \
                  "$database_password" \
                  >> ${environmentFile}
              fi

              chown ${cfg.name}:${cfg.name} ${environmentFile}
            '';
          };
        };

        streamystats-database-extensions = {
          description = "Create Streamystats PostgreSQL extensions";
          after = ["postgresql.service"];
          requires = ["postgresql.service"];
          before = ["streamystats-migrate.service"];
          requiredBy = ["streamystats-migrate.service"];
          serviceConfig = {
            Type = "oneshot";
            User = "postgres";
            ExecStart = pkgs.writeShellScript "streamystats-database-extensions" ''
              ${lib.getExe' config.services.postgresql.package "psql"} --dbname=${cfg.name} \
                --command='CREATE EXTENSION IF NOT EXISTS vector' \
                --command='CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'
            '';
          };
        };
      };

      services.postgresql.extensions = ps: [ps.pgvector];

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 700 ${cfg.name} ${cfg.name} - -"
      ];

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
          restore.stopOnRestore = [
            "streamystats.service"
            "streamystats-job-server.service"
          ];
        };
        users.${cfg.name} = {};
      };

      clan.core.state.${cfg.name}.folders = [cfg.dataDir];

      services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}".locations."/".extraConfig = ''
        proxy_redirect ~^https?://localhost:${toString cfg.port}(/.*)$ https://${cfg.domainName}.${homelab.baseDomain}$1;
      '';
    })
  ];
}
