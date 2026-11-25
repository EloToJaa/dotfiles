{
  pkgs,
  config,
  lib,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.loki;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "loki";
    port = 3100;
    glance.icon = "di:loki";
    gatus = {
      name = "Loki";
      group = "monitoring";
      path = "/ready";
    };
    forwardAuth = {};
  };
in {
  options.modules.homelab.loki =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.main;
      };
      retention = lib.mkOption {
        type = lib.types.str;
        default = "744h";
        description = "How long Loki keeps log lines";
      };
    };
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      modules.homelab.prometheus.scrapeTargets = [
        {
          job_name = "loki";
          address = "127.0.0.1:${toString cfg.port}";
        }
      ];

      services.loki = {
        inherit (cfg) dataDir group;
        enable = true;
        package = pkgs.unstable.grafana-loki;
        user = cfg.name;
        configuration = {
          auth_enabled = false;
          server = {
            http_listen_address = "127.0.0.1";
            http_listen_port = cfg.port;
          };
          common = {
            path_prefix = cfg.dataDir;
            replication_factor = 1;
            ring.kvstore.store = "inmemory";
            storage.filesystem = {
              chunks_directory = "${cfg.dataDir}/chunks";
              rules_directory = "${cfg.dataDir}/rules";
            };
          };
          limits_config.retention_period = cfg.retention;
          compactor = {
            working_directory = "${cfg.dataDir}/compactor";
            retention_enabled = true;
            delete_request_store = "filesystem";
          };
          schema_config.configs = [
            {
              from = "2024-01-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };
      };
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      ];

      services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}".locations =
        {
          "= /metrics".return = "404";
        }
        // lib.genAttrs ["= /loki/api/v1/push" "= /api/prom/push" "^~ /otlp/"] (_: {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          basicAuthFile = config.clan.core.vars.generators.alloy-ingest-htpasswd.files.htpasswd.path;
        });

      clan.core.state.loki = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop loki.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start loki.service
        '';
      };
    })
  ];
}
