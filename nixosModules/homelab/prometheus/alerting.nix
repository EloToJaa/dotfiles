{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.prometheus.alerting;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  filesystems = ''fstype!~"tmpfs|ramfs|devtmpfs|overlay|squashfs|nsfs|autofs|fuse.*"'';
  usedRatio = "1 - node_filesystem_avail_bytes{${filesystems}} / node_filesystem_size_bytes{${filesystems}}";
  rule = alert: severity: expr: for: summary: description: {
    inherit alert expr for;
    labels.severity = severity;
    annotations = {inherit summary description;};
  };
  rulesFile = (pkgs.formats.yaml {}).generate "alerts.yml" {
    groups = [
      {
        name = "hosts";
        rules = [
          (rule "HostDown" "critical"
            (lib.concatMapStringsSep " or " (host: ''absent_over_time(up{host="${host}"}[10m])'') cfg.hosts)
            "5m"
            "{{ $labels.host }} stopped reporting metrics"
            "No samples from {{ $labels.host }} for 15 minutes. Check the host and its Alloy remote_write.")
          (rule "TargetDown" "warning" "up == 0" "5m"
            "{{ $labels.job }} on {{ $labels.host }} is down"
            "Prometheus has failed to scrape {{ $labels.job }} on {{ $labels.host }} for 5 minutes.")
          (rule "SystemdUnitFailed" "warning" ''node_systemd_unit_state{state="failed"} == 1'' "5m"
            "{{ $labels.name }} failed on {{ $labels.host }}"
            "systemd unit {{ $labels.name }} on {{ $labels.host }} is in the failed state.")
        ];
      }
      {
        name = "filesystems";
        rules = [
          (rule "FilesystemAlmostFull" "warning" "max by (host, device) (${usedRatio}) > 0.85" "15m"
            "{{ $labels.device }} on {{ $labels.host }} is {{ $value | humanizePercentage }} full"
            "Filesystem {{ $labels.device }} on {{ $labels.host }} is over 85% full.")
          (rule "FilesystemFillingUp" "critical"
            "min by (host, device) (predict_linear(node_filesystem_avail_bytes{${filesystems}}[6h], 24 * 3600)) < 0 and max by (host, device) (${usedRatio}) > 0.6"
            "1h"
            "{{ $labels.device }} on {{ $labels.host }} will fill within 24h"
            "At the rate of the last 6 hours, filesystem {{ $labels.device }} on {{ $labels.host }} runs out of space within 24 hours.")
        ];
      }
      {
        name = "disks";
        rules = [
          (rule "SmartDeviceUnhealthy" "critical" "smartctl_device_smart_status == 0" "5m"
            "SMART health check failed for {{ $labels.device }} on {{ $labels.host }}"
            "smartctl reports {{ $labels.device }} on {{ $labels.host }} as failing its overall health self-assessment.")
          (rule "SmartCriticalWarning" "critical" "smartctl_device_critical_warning > 0" "5m"
            "NVMe critical warning on {{ $labels.device }} on {{ $labels.host }}"
            "{{ $labels.device }} on {{ $labels.host }} reports critical warning flags {{ $value }}.")
          (rule "SmartMediaErrors" "warning" "increase(smartctl_device_media_errors[1h]) > 0" "0m"
            "New media errors on {{ $labels.device }} on {{ $labels.host }}"
            "{{ $labels.device }} on {{ $labels.host }} logged {{ $value }} new media errors in the last hour.")
        ];
      }
      {
        name = "memory";
        rules = [
          (rule "MemoryPressure" "warning" "rate(node_pressure_memory_waiting_seconds_total[5m]) > 0.25" "15m"
            "Sustained memory pressure on {{ $labels.host }}"
            "Tasks on {{ $labels.host }} spent {{ $value | humanizePercentage }} of the time waiting on memory for 15 minutes.")
          (rule "LowMemory" "warning" "node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1" "15m"
            "{{ $labels.host }} is low on memory"
            "Only {{ $value | humanizePercentage }} of memory has been available on {{ $labels.host }} for 15 minutes.")
          (rule "OomKill" "warning" "increase(node_vmstat_oom_kill[10m]) > 0" "0m"
            "OOM killer ran on {{ $labels.host }}"
            "The kernel OOM killer killed {{ $value | humanize }} processes on {{ $labels.host }} in the last 10 minutes.")
        ];
      }
      {
        name = "monitoring";
        rules = [
          (rule "PrometheusRuleEvaluationFailures" "critical" "increase(prometheus_rule_evaluation_failures_total[10m]) > 0" "0m"
            "Prometheus rule evaluation is failing"
            "Rule group {{ $labels.rule_group }} failed {{ $value | humanize }} evaluations in the last 10 minutes.")
          (rule "PrometheusConfigReloadFailed" "warning" "prometheus_config_last_reload_successful == 0" "10m"
            "Prometheus failed to reload its configuration"
            "The last Prometheus configuration reload failed.")
          (rule "RemoteWriteReceiverErrors" "warning"
            ''sum by (code) (rate(prometheus_http_requests_total{handler="/api/v1/write", code!~"2.."}[5m])) > 0''
            "10m"
            "Prometheus is rejecting remote_write requests"
            "The remote_write receiver has answered with HTTP {{ $labels.code }} for 10 minutes.")
          (rule "RemoteWriteSamplesRejected" "warning"
            ''sum(rate({__name__=~"prometheus_tsdb_(out_of_order|too_old)_samples_total"}[5m])) > 0''
            "15m"
            "Prometheus is dropping out-of-order or too-old samples"
            "Prometheus has rejected {{ $value | humanize }} samples per second for 15 minutes, usually from a remote_write sender with clock skew or a stuck queue.")
          (rule "RemoteStorageSendFailures" "warning" "rate(prometheus_remote_storage_samples_failed_total[5m]) > 0" "15m"
            "{{ $labels.job }} on {{ $labels.host }} fails to remote_write samples"
            "{{ $labels.job }} on {{ $labels.host }} has failed to send samples to Prometheus for 15 minutes.")
          (rule "AlertmanagerNotificationsFailing" "warning" "rate(alertmanager_notifications_failed_total[5m]) > 0" "10m"
            "Alertmanager fails to deliver notifications"
            "Alertmanager has failed to deliver notifications through {{ $labels.integration }} for 10 minutes.")
        ];
      }
    ];
  };
in {
  options.modules.homelab.prometheus.alerting = {
    enable = lib.mkEnableOption "Prometheus alerting rules with Alertmanager notifications to ntfy";
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "alertmanager";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9093;
    };
    ntfyBridgePort = lib.mkOption {
      type = lib.types.port;
      default = 9099;
      description = "Local port of alertmanager-ntfy, which forwards Alertmanager webhooks to ntfy.";
    };
    hosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = lib.filter (host: inputs.self.nixosConfigurations.${host}.config.modules.homelab.alloy.enable) (
        lib.attrNames inputs.self.nixosConfigurations
      );
      defaultText = lib.literalMD "every flake host with `modules.homelab.alloy.enable`";
      description = "Hosts expected to report metrics. HostDown fires when one of them stops sending samples.";
    };
    ntfy = {
      url = lib.mkOption {
        type = lib.types.str;
        default = config.settings.ntfy;
        description = "ntfy server that receives alerts.";
      };
      topic = lib.mkOption {
        type = lib.types.str;
        default = "alerts";
        description = "ntfy topic that receives alerts.";
      };
    };
  };

  config = lib.mkIf (homelab.prometheus.enable && cfg.enable) {
    services.prometheus = {
      webExternalUrl = "https://${homelab.prometheus.domainName}.${homelab.baseDomain}";
      ruleFiles = [rulesFile];
      alertmanagers = [
        {
          static_configs = [
            {targets = ["127.0.0.1:${toString cfg.port}"];}
          ];
        }
      ];

      alertmanager = {
        enable = true;
        package = pkgs.unstable.prometheus-alertmanager;
        listenAddress = "127.0.0.1";
        inherit (cfg) port;
        webExternalUrl = "https://${domain}";
        extraFlags = ["--cluster.listen-address="];
        configuration = {
          route = {
            receiver = "ntfy";
            group_by = ["alertname" "host"];
            group_wait = "30s";
            group_interval = "5m";
            repeat_interval = "12h";
          };
          inhibit_rules = [
            {
              source_matchers = [''alertname="HostDown"''];
              target_matchers = [''alertname!="HostDown"''];
              equal = ["host"];
            }
          ];
          receivers = [
            {
              name = "ntfy";
              webhook_configs = [
                {
                  url = "http://127.0.0.1:${toString cfg.ntfyBridgePort}/hook";
                  send_resolved = true;
                }
              ];
            }
          ];
        };
      };

      alertmanager-ntfy = {
        enable = true;
        settings = {
          http.addr = "127.0.0.1:${toString cfg.ntfyBridgePort}";
          ntfy = {
            baseurl = cfg.ntfy.url;
            notification = {
              inherit (cfg.ntfy) topic;
              priority = ''status == "resolved" ? "default" : (labels.severity == "critical" ? "urgent" : "high")'';
              templates.headers.X-Click = "{{ .GeneratorURL }}";
            };
          };
        };
        extraConfigFiles = [
          config.clan.core.vars.generators.alertmanager-ntfy-config.files."config.yml".path
        ];
      };
    };

    modules.homelab.prometheus.scrapeTargets = [
      {
        job_name = "alertmanager";
        address = "127.0.0.1:${toString cfg.port}";
      }
    ];

    modules.homelab.gatus.endpoints = [
      {
        name = "Alertmanager";
        group = "monitoring";
        url = "https://${domain}/-/healthy";
        conditions = ["[STATUS] == 200"];
      }
    ];

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    clan.core.vars.generators = {
      alertmanager-ntfy = {
        prompts.token = {
          description = "ntfy access token for Alertmanager alerts (ntfy token add <user>), with write access to the ${cfg.ntfy.topic} topic";
          type = "hidden";
          persist = true;
        };
        files.token.deploy = false;
      };
      alertmanager-ntfy-config = {
        dependencies = ["alertmanager-ntfy"];
        files."config.yml" = {};
        script = ''
          printf 'ntfy:\n  auth:\n    token: "%s"\n' "$(cat "$in/alertmanager-ntfy/token")" > "$out/config.yml"
        '';
      };
    };
  };
}
