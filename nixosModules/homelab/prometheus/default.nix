{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.prometheus;
in {
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
  };
  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      package = pkgs.unstable.prometheus;
      inherit (cfg) port stateDir;
      listenAddress = "127.0.0.1";
      scrapeConfigs = [
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
            }
          ];
        }
        {
          job_name = "grafana";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString homelab.grafana.port}"
              ];
            }
          ];
        }
        {
          job_name = "loki";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString homelab.loki.port}"
              ];
            }
          ];
        }
      ];
      exporters.node = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = cfg.nodeExporterPort;
        enabledCollectors = [
          "systemd"
        ];
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
  };
}
