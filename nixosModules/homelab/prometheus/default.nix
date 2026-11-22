{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.networking) hostName;
  cfg = config.modules.homelab.prometheus;
  jobNames = map (target: target.job_name) cfg.scrapeTargets;
  scrapeConfigs =
    [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString cfg.port}"
            ];
          }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString cfg.nodeExporterPort}"
            ];
            labels.host = hostName;
          }
        ];
      }
    ]
    ++ map (target: {
      inherit (target) job_name metrics_path;
      static_configs = [
        {
          targets = [target.address];
          labels = target.labels // {host = hostName;};
        }
      ];
    })
    cfg.scrapeTargets;
in {
  imports = [
    ./exportarr.nix
    ./exporters.nix
  ];

  options.modules.homelab.prometheus = {
    enable = lib.mkEnableOption "Enable prometheus";
    name = lib.mkOption {
      type = lib.types.str;
      default = "prometheus";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "prometheus";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
    };
    stateDir = lib.mkOption {
      type = lib.types.str;
      default = cfg.name;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.stateDir}";
    };
    nodeExporterPort = lib.mkOption {
      type = lib.types.port;
      default = 9100;
    };
    nodeCollectors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["systemd"];
      description = "Extra node exporter collectors, shared by the node exporter on the Prometheus host and Alloy's embedded one on the other hosts.";
    };
    outOfOrderTimeWindow = lib.mkOption {
      type = lib.types.str;
      default = "30m";
      description = "How far behind the newest sample of a series Prometheus still accepts samples, so remote-writing hosts can replay their buffer after a network outage. Written as storage.tsdb.out_of_order_time_window in the generated config, because the NixOS module has no option for it and a flag does not exist.";
    };
    scrapeTargets = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          job_name = lib.mkOption {
            type = lib.types.str;
            description = "Prometheus job name, unique per host.";
          };
          address = lib.mkOption {
            type = lib.types.str;
            example = "127.0.0.1:9187";
            description = "host:port of the metrics endpoint.";
          };
          metrics_path = lib.mkOption {
            type = lib.types.str;
            default = "/metrics";
            description = "HTTP path of the metrics endpoint.";
          };
          labels = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
            description = "Extra labels attached to every sample of the target.";
          };
        };
      });
      default = [];
      description = "Metrics endpoints on this host. Each homelab module appends its own. Prometheus scrapes them directly on its own host, Alloy scrapes and remote-writes them on the others.";
    };
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = lib.length jobNames == lib.length (lib.unique jobNames);
          message = "modules.homelab.prometheus.scrapeTargets must use unique job_name values per host, got: ${lib.concatStringsSep ", " jobNames}";
        }
      ];
    }
    (lib.mkIf cfg.enable {
      modules.homelab.gatus.endpoints = [
        {
          name = "Prometheus";
          group = "monitoring";
          url = "https://${cfg.domainName}.${homelab.baseDomain}/-/healthy";
          conditions = ["[STATUS] == 200"];
        }
      ];

      services.prometheus = {
        enable = true;
        package = pkgs.unstable.prometheus;
        inherit (cfg) port stateDir;
        listenAddress = "127.0.0.1";
        extraFlags = [
          "--web.enable-remote-write-receiver"
          "--enable-feature=exemplar-storage"
        ];
        configText = builtins.toJSON {
          scrape_configs = scrapeConfigs;
          storage.tsdb.out_of_order_time_window = cfg.outOfOrderTimeWindow;
        };
        exporters.node = {
          enable = true;
          listenAddress = "127.0.0.1";
          port = cfg.nodeExporterPort;
          enabledCollectors = cfg.nodeCollectors;
        };
      };
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      ];

      services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
        forceSSL = true;
        useACMEHost = homelab.baseDomain;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };

      clan.core.state.prometheus = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop prometheus.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start prometheus.service
        '';
      };
    })
  ];
}
