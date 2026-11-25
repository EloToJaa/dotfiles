{
  pkgs,
  config,
  lib,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.grafana;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "grafana";
    port = 3002;
    glance.icon = "di:grafana";
    gatus = {
      name = "Grafana";
      group = "monitoring";
      path = "/api/health";
    };
  };
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.grafana =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.main;
      };
    };
  imports = [
    ./auth.nix
  ];
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      modules.homelab.prometheus.scrapeTargets = [
        {
          job_name = "grafana";
          address = "127.0.0.1:${toString cfg.port}";
        }
      ];

      services.grafana = {
        inherit (cfg) dataDir;
        enable = true;
        package = pkgs.unstable.grafana;
        settings = {
          analytics.reporting_enabled = false;
          security = {
            secret_key = "$__file{${config.clan.core.vars.generators."${cfg.name}-secret-key".files.secret-key.path}}";
            admin_password = "$__file{${config.clan.core.vars.generators."${cfg.name}-admin".files.password.path}}";
          };
          server = {
            inherit domain;
            http_addr = "127.0.0.1";
            http_port = cfg.port;
            root_url = "https://${domain}/";
          };
        };
        provision.datasources.settings = {
          apiVersion = 1;
          datasources =
            [
              {
                name = "Prometheus";
                type = "prometheus";
                uid = "prometheus";
                url = "http://127.0.0.1:${toString homelab.prometheus.port}";
                isDefault = true;
                jsonData.exemplarTraceIdDestinations = lib.optional homelab.tempo.enable {
                  name = "trace_id";
                  datasourceUid = "tempo";
                };
              }
              {
                name = "Loki";
                type = "loki";
                uid = "loki";
                url = "http://127.0.0.1:${toString homelab.loki.port}";
                jsonData.derivedFields = lib.optional homelab.tempo.enable {
                  name = "TraceID";
                  matcherRegex = "(?:trace_id|traceID|traceId)[=:\"\\s]+(\\w+)";
                  url = "$${__value.raw}";
                  datasourceUid = "tempo";
                };
              }
            ]
            ++ lib.optional homelab.tempo.enable {
              name = "Tempo";
              type = "tempo";
              uid = "tempo";
              url = "http://127.0.0.1:${toString homelab.tempo.port}";
              jsonData = {
                streamingEnabled = {
                  search = true;
                  metrics = true;
                };
                serviceMap.datasourceUid = "prometheus";
                nodeGraph.enabled = true;
                tracesToLogsV2 = {
                  datasourceUid = "loki";
                  spanStartTimeShift = "-5m";
                  spanEndTimeShift = "5m";
                  tags = [
                    {
                      key = "host.name";
                      value = "host";
                    }
                  ];
                };
                tracesToMetrics = {
                  datasourceUid = "prometheus";
                  tags = [
                    {
                      key = "service.name";
                      value = "service";
                    }
                  ];
                  queries = [
                    {
                      name = "Request rate";
                      query = "sum(rate(traces_spanmetrics_calls_total{$$__tags}[5m]))";
                    }
                    {
                      name = "p95 latency";
                      query = "histogram_quantile(0.95, sum by (le) (rate(traces_spanmetrics_latency_bucket{$$__tags}[5m])))";
                    }
                  ];
                };
              };
            };
        };
        provision.dashboards.settings = {
          apiVersion = 1;
          providers = [
            {
              name = "homelab";
              type = "file";
              allowUiUpdates = false;
              options = {
                path = ./dashboards;
                foldersFromFilesStructure = true;
              };
            }
          ];
        };
      };
      clan.core.vars.generators."${cfg.name}-secret-key" = {
        runtimeInputs = [pkgs.openssl];
        files.secret-key.owner = cfg.name;
        script = ''
          openssl rand -base64 48 | tr -d '\n' > "$out/secret-key"
        '';
      };

      clan.core.vars.generators."${cfg.name}-admin" = {
        runtimeInputs = [pkgs.pwgen];
        files.password.owner = cfg.name;
        script = ''
          pwgen -s 48 1 | tr -d '\n' > "$out/password"
        '';
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      ];

      services.nginx.virtualHosts.${domain}.locations."= /metrics".return = "404";

      clan.core.state.grafana = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop grafana.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start grafana.service
        '';
      };
    })
  ];
}
