{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.grafana;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.grafana = {
    enable = lib.mkEnableOption "Enable grafana";
    name = lib.mkOption {
      type = lib.types.str;
      default = "grafana";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "grafana";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3002;
    };
  };
  config = lib.mkIf cfg.enable {
    modules.homelab.gatus.endpoints = [
      {
        name = "Grafana";
        group = "monitoring";
        url = "https://${cfg.domainName}.${homelab.baseDomain}/api/health";
        conditions = ["[STATUS] == 200"];
      }
    ];

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
        security.secret_key = "$__file{${cfg.dataDir}/secret_key}";
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
    systemd.services.grafana.preStart = ''
      if [ ! -s ${cfg.dataDir}/secret_key ]; then
        ${pkgs.openssl}/bin/openssl rand -base64 48 > ${cfg.dataDir}/secret_key
        chmod 600 ${cfg.dataDir}/secret_key
      fi
    '';
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
        "= /metrics".return = "404";
      };
    };

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
  };
}
