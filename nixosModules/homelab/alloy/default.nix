{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.networking) hostName;
  cfg = config.modules.homelab.alloy;
  monitoringHost = "server.${homelab.mainDomain}";
  shipMetrics = !homelab.prometheus.enable;
  shipLogs = !homelab.loki.enable;
  shipTraces = !homelab.tempo.enable;
  needsIngestAuth = shipMetrics || shipLogs || shipTraces;
  ingestUser = "alloy";
  ingestServer = homelab.loki.enable || homelab.tempo.enable || homelab.prometheus.enable;
  ingestPasswordCredential = "ingest-password";
  ingestPassword = config.clan.core.vars.generators.alloy-ingest.files.password.path;
  basicAuthBlock = ''
    basic_auth {
          username = "${ingestUser}"
          password = local.file.ingest_password.content
        }
  '';
  alloyString = builtins.toJSON;
  redactStages =
    lib.concatMapStrings (pattern: ''

      ${"  "}stage.replace {
          expression = `${pattern}`
          replace    = "<redacted>"
        }
    '')
    cfg.redactPatterns;
  scrapeBlock = target: let
    labels = {__address__ = target.address;} // target.labels;
    targetObject = lib.concatStringsSep ", " (lib.mapAttrsToList (name: value: "${alloyString name} = ${alloyString value}") labels);
  in ''
    prometheus.scrape ${alloyString (lib.replaceStrings ["-"] ["_"] target.job_name)} {
      targets      = [{${targetObject}}]
      job_name     = ${alloyString target.job_name}
      metrics_path = ${alloyString target.metrics_path}
      forward_to   = [prometheus.relabel.host.receiver]
    }
  '';
in {
  options.modules.homelab.alloy = {
    enable = lib.mkEnableOption "Grafana Alloy, shipping the systemd journal to Loki, host metrics to Prometheus and OTLP traces to Tempo";
    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default =
        if homelab.loki.enable
        then "http://127.0.0.1:${toString homelab.loki.port}"
        else "https://loki.${monitoringHost}";
      description = "Base URL of the Loki instance that receives the journal";
    };
    tempoUrl = lib.mkOption {
      type = lib.types.str;
      default =
        if homelab.tempo.enable
        then "http://127.0.0.1:${toString homelab.tempo.otlpHttpPort}"
        else "https://tempo.${monitoringHost}";
      description = "Base URL of the Tempo OTLP HTTP endpoint that receives traces";
    };
    otlpGrpcPort = lib.mkOption {
      type = lib.types.port;
      default = 4317;
      description = "Local OTLP gRPC port where applications send traces";
    };
    otlpHttpPort = lib.mkOption {
      type = lib.types.port;
      default = 4318;
      description = "Local OTLP HTTP port where applications send traces";
    };
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address of Alloy's HTTP server, which serves its UI and its own metrics";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 12345;
      description = "Port of Alloy's HTTP server, which serves its UI and its own metrics";
    };
    prometheusUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://prometheus.${monitoringHost}";
      description = "Base URL of the Prometheus instance that receives host metrics through remote_write, on hosts without a local Prometheus";
    };
    redactPatterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        ''(?i)(?:^|[?&\s])[a-z0-9_.-]*(?:key|token|secret|password|passwd|signature)=([^&\s"',;]+)''
        ''(?i)[?&](?:sig|auth|code)=([^&\s"',;]+)''
        ''(?i)"[a-z0-9_.-]*(?:key|token|secret|password|passwd)"\s*:\s*"([^"]+)"''
        ''(?i)\b(?:bearer|basic)\s+([a-z0-9._~+/=-]{8,})''
      ];
      description = "RE2 regexes applied to every journal line before it reaches Loki. Each pattern's capture groups are replaced with <redacted>, so capture only the secret value.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable || ingestServer) {
      clan.core.vars.generators.alloy-ingest = {
        share = true;
        files.password.secret = true;
        runtimeInputs = [pkgs.pwgen];
        script = ''
          pwgen -s 64 1 | tr -d '\n' > "$out/password"
        '';
      };
    })

    (lib.mkIf ingestServer {
      clan.core.vars.generators.alloy-ingest-htpasswd = {
        dependencies = ["alloy-ingest"];
        files.htpasswd = {
          secret = true;
          owner = homelab.nginx.name;
        };
        runtimeInputs = [pkgs.apacheHttpd];
        script = ''
          htpasswd -icB $out/htpasswd "${ingestUser}" < $in/alloy-ingest/password
        '';
      };
    })

    (lib.mkIf cfg.enable {
      services.alloy = {
        enable = true;
        package = pkgs.unstable.grafana-alloy;
        extraFlags = [
          "--disable-reporting"
          "--server.http.listen-addr=${cfg.listenAddress}:${toString cfg.port}"
        ];
      };

      systemd.services.alloy.serviceConfig.LoadCredential = lib.mkIf needsIngestAuth [
        "${ingestPasswordCredential}:${ingestPassword}"
      ];

      environment.etc."alloy/ingest.alloy" = lib.mkIf needsIngestAuth {
        text = ''
          local.file "ingest_password" {
            filename  = sys.env("CREDENTIALS_DIRECTORY") + "/${ingestPasswordCredential}"
            is_secret = true
          }
        '';
      };

      modules.homelab.prometheus.scrapeTargets = [
        {
          job_name = "alloy";
          address = "${cfg.listenAddress}:${toString cfg.port}";
        }
      ];

      environment.etc."alloy/logs.alloy".text = ''
        loki.relabel "journal" {
          forward_to = []

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }

          rule {
            source_labels = ["__journal__systemd_user_unit"]
            target_label  = "user_unit"
          }

          rule {
            source_labels = ["__journal_syslog_identifier"]
            target_label  = "syslog_identifier"
          }

          rule {
            source_labels = ["__journal_priority_keyword"]
            target_label  = "level"
          }
        }

        loki.source.journal "journal" {
          max_age       = "12h"
          relabel_rules = loki.relabel.journal.rules
          labels        = {job = "systemd-journal", host = "${hostName}"}
          forward_to    = [loki.process.redact.receiver]
        }

        loki.process "redact" {
          forward_to = [loki.write.default.receiver]

          stage.match {
            selector = "{syslog_identifier=\"${homelab.nginx.accessLogTag}\"}"

            stage.static_labels {
              values = {job = "nginx"}
            }

            stage.json {
              expressions = {vhost = ""}
            }

            stage.labels {
              values = {vhost = ""}
            }
          }
        ${redactStages}
        }

        loki.write "default" {
          endpoint {
            url = "${cfg.lokiUrl}/loki/api/v1/push"
            ${lib.optionalString shipLogs basicAuthBlock}
          }
        }
      '';

      environment.etc."alloy/traces.alloy".text = ''
        otelcol.receiver.otlp "default" {
          grpc {
            endpoint = "127.0.0.1:${toString cfg.otlpGrpcPort}"
          }

          http {
            endpoint = "127.0.0.1:${toString cfg.otlpHttpPort}"
          }

          output {
            traces = [otelcol.processor.resourcedetection.default.input]
          }
        }

        otelcol.processor.resourcedetection "default" {
          detectors = ["system"]

          system {
            hostname_sources = ["os"]
          }

          output {
            traces = [otelcol.processor.batch.default.input]
          }
        }

        otelcol.processor.batch "default" {
          output {
            traces = [otelcol.exporter.otlphttp.tempo.input]
          }
        }

        ${lib.optionalString shipTraces ''
          otelcol.auth.basic "ingest" {
            username = "${ingestUser}"
            password = local.file.ingest_password.content
          }
        ''}
        otelcol.exporter.otlphttp "tempo" {
          client {
            endpoint = "${cfg.tempoUrl}"
            ${lib.optionalString shipTraces "auth     = otelcol.auth.basic.ingest.handler"}
          }
        }
      '';

      environment.etc."alloy/metrics.alloy" = lib.mkIf shipMetrics {
        text = ''
          prometheus.exporter.unix "node" {
            enable_collectors = [${lib.concatMapStringsSep ", " alloyString homelab.prometheus.nodeCollectors}]
          }

          prometheus.scrape "node" {
            targets    = prometheus.exporter.unix.node.targets
            job_name   = "node"
            forward_to = [prometheus.relabel.host.receiver]
          }

          ${lib.concatMapStringsSep "\n" scrapeBlock homelab.prometheus.scrapeTargets}

          prometheus.relabel "host" {
            forward_to = [prometheus.remote_write.default.receiver]

            rule {
              target_label = "host"
              replacement  = "${hostName}"
            }

            rule {
              target_label = "instance"
              replacement  = "${hostName}"
            }
          }

          prometheus.remote_write "default" {
            endpoint {
              url = "${cfg.prometheusUrl}/api/v1/write"
              ${lib.optionalString shipMetrics basicAuthBlock}
            }
          }
        '';
      };
    })
  ];
}
