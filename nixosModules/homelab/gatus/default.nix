{
  lib,
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.gatus;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "gatus";
    port = 3011;
    domainName = "status";
    dataDir = false;
    glance = {
      title = "Gatus";
      group = "monitoring";
      icon = "di:gatus";
    };
  };
in {
  options.modules.homelab.gatus =
    service.options
    // {
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
      ntfy = {
        url = lib.mkOption {
          type = lib.types.str;
          default = config.settings.ntfy;
          description = "ntfy server that receives Gatus alerts.";
        };
        topic = lib.mkOption {
          type = lib.types.str;
          default = "uptime";
          description = "ntfy topic that receives Gatus alerts.";
        };
      };
    };
  imports = [
    ./auth.nix
  ];
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.gatus = {
        enable = true;
        environmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
        settings = {
          metrics = true;
          web = {
            address = "127.0.0.1";
            inherit (cfg) port;
          };
          storage = {
            type = "postgres";
            path = "postgres://${cfg.name}:\${GATUS_POSTGRES_PASSWORD}@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}?sslmode=disable";
          };
          alerting.ntfy = {
            inherit (cfg.ntfy) url topic;
            token = "\${GATUS_NTFY_TOKEN}";
            default-alert = {
              failure-threshold = 3;
              success-threshold = 2;
              send-on-resolved = true;
            };
          };
          endpoints = map (endpoint: {alerts = [{type = "ntfy";}];} // endpoint) (
            cfg.endpoints
            ++ lib.concatMap (
              host: inputs.self.nixosConfigurations.${host}.config.modules.homelab.gatus.endpoints
            )
            cfg.hosts
          );
        };
      };
      modules.homelab.prometheus.scrapeTargets = [
        {
          job_name = "gatus";
          address = "127.0.0.1:${toString cfg.port}";
        }
      ];

      systemd.services.gatus = {
        after = ["postgresql.target"];
        wants = ["postgresql.target"];
      };

      services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}".locations."= /metrics".return = "404";

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
        "${cfg.name}-ntfy" = {
          prompts.token = {
            description = "ntfy access token for Gatus alerts (ntfy token add <user>), with write access to the ${cfg.ntfy.topic} topic";
            type = "hidden";
            persist = true;
          };
          files.token.deploy = false;
        };
        "${cfg.name}-env" = {
          dependencies = [
            cfg.name
            "${cfg.name}-ntfy"
          ];
          files.env = {};
          script = ''
            {
              printf 'GATUS_POSTGRES_PASSWORD=%s\n' "$(cat "$in/${cfg.name}/pgpassword")"
              printf 'GATUS_NTFY_TOKEN=%s\n' "$(cat "$in/${cfg.name}-ntfy/token")"
            } > "$out/env"
          '';
        };
      };
    })
  ];
}
