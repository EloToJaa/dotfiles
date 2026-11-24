{
  pkgs,
  config,
  lib,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.networking) hostName;
  cfg = config.modules.homelab.tempo;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "tempo";
    port = 3200;
    description = "Grafana Tempo, storing traces and deriving span metrics into Prometheus";
    proxyWebsockets = false;
    gatus = {
      name = "Tempo";
      group = "monitoring";
      path = "/ready";
    };
  };
  configFile = (pkgs.formats.yaml {}).generate "tempo.yaml" {
    stream_over_http_enabled = true;
    usage_report.reporting_enabled = false;
    server = {
      http_listen_address = "127.0.0.1";
      http_listen_port = cfg.port;
      grpc_listen_address = "127.0.0.1";
      grpc_listen_port = cfg.grpcPort;
    };
    memberlist.bind_addr = ["127.0.0.1"];
    distributor.receivers.otlp.protocols = {
      grpc.endpoint = "127.0.0.1:${toString cfg.otlpGrpcPort}";
      http.endpoint = "127.0.0.1:${toString cfg.otlpHttpPort}";
    };
    live_store = {
      wal.path = "${cfg.dataDir}/live-store/traces";
      shutdown_marker_dir = "${cfg.dataDir}/live-store/shutdown-marker";
    };
    block_builder.wal.path = "${cfg.dataDir}/block-builder/traces";
    backend_scheduler = {
      local_work_path = cfg.dataDir;
      provider.compaction.compaction.block_retention = cfg.retention;
    };
    backend_worker.compaction.block_retention = cfg.retention;
    metrics_generator = {
      registry.external_labels = {
        source = "tempo";
        host = hostName;
      };
      storage = {
        path = "${cfg.dataDir}/generator/wal";
        remote_write = [
          {
            url = "http://127.0.0.1:${toString homelab.prometheus.port}/api/v1/write";
            send_exemplars = true;
          }
        ];
      };
    };
    storage.trace = {
      backend = "local";
      wal.path = "${cfg.dataDir}/wal";
      local.path = "${cfg.dataDir}/blocks";
    };
    overrides.defaults.metrics_generator = {
      processors = ["span-metrics" "service-graphs"];
      processor.span_metrics.dimensions = ["net.host.name" "host.name"];
    };
  };
in {
  options.modules.homelab.tempo =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.main;
      };
      grpcPort = lib.mkOption {
        type = lib.types.port;
        default = 9096;
        description = "Internal gRPC port, moved off 9095 which Loki uses";
      };
      otlpGrpcPort = lib.mkOption {
        type = lib.types.port;
        default = 4417;
        description = "OTLP gRPC receiver port, kept off 4317 which the local Alloy uses";
      };
      otlpHttpPort = lib.mkOption {
        type = lib.types.port;
        default = 4418;
        description = "OTLP HTTP receiver port, kept off 4318 which the local Alloy uses";
      };
      retention = lib.mkOption {
        type = lib.types.str;
        default = "744h";
        description = "How long Tempo keeps traces";
      };
    };

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = homelab.prometheus.enable;
          message = "modules.homelab.tempo remote-writes span metrics to the local Prometheus, enable modules.homelab.prometheus";
        }
      ];

      modules.homelab.prometheus.scrapeTargets = [
        {
          job_name = "tempo";
          address = "127.0.0.1:${toString cfg.port}";
        }
      ];

      services.tempo = {
        enable = true;
        inherit configFile;
      };
      systemd.services.tempo.serviceConfig = {
        ExecStart = lib.mkForce "${pkgs.unstable.tempo}/bin/tempo --config.file=${configFile}";
        DynamicUser = lib.mkForce false;
        User = cfg.name;
        Group = cfg.group;
        WorkingDirectory = lib.mkForce cfg.dataDir;
      };

      users.users.${cfg.name} = {
        isSystemUser = true;
        inherit (cfg) group;
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      ];

      services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}".locations = {
        "= /v1/traces" = {
          proxyPass = "http://127.0.0.1:${toString cfg.otlpHttpPort}";
          basicAuthFile = config.clan.core.vars.generators.alloy-ingest-htpasswd.files.htpasswd.path;
        };
        "= /metrics".return = "404";
      };

      clan.core.state.tempo = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop tempo.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start tempo.service
        '';
      };
    })
  ];
}
