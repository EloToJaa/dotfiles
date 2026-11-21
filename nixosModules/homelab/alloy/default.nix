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
in {
  options.modules.homelab.alloy = {
    enable =
      lib.mkEnableOption "Grafana Alloy, shipping the systemd journal to Loki and host metrics to Prometheus"
      // {default = homelab.enable;};
    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default =
        if homelab.loki.enable
        then "http://127.0.0.1:${toString homelab.loki.port}"
        else "https://loki.${monitoringHost}";
      description = "Base URL of the Loki instance that receives the journal";
    };
    prometheusUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://prometheus.${monitoringHost}";
      description = "Base URL of the Prometheus instance that receives host metrics through remote_write, on hosts without a local Prometheus";
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
      package = pkgs.unstable.grafana-alloy;
      extraFlags = ["--disable-reporting"];
    };

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
        forward_to    = [loki.write.default.receiver]
      }

      loki.write "default" {
        endpoint {
          url = "${cfg.lokiUrl}/loki/api/v1/push"
        }
      }
    '';

    environment.etc."alloy/metrics.alloy" = lib.mkIf shipMetrics {
      text = ''
        prometheus.exporter.unix "node" {
          enable_collectors = ["systemd"]
        }

        prometheus.scrape "node" {
          targets    = prometheus.exporter.unix.node.targets
          job_name   = "node"
          forward_to = [prometheus.relabel.host.receiver]
        }

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
          }
        }
      '';
    };
  };
}
