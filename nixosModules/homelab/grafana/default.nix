{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.grafana;
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
      default = "${homelab.dataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3002;
    };
  };
  config = lib.mkIf cfg.enable {
    services.grafana = {
      inherit (cfg) dataDir;
      enable = true;
      package = pkgs.unstable.grafana;
      settings = {
        analytics.reporting_enabled = false;
        security.secret_key = "$__file{${cfg.dataDir}/secret_key}";
        server = {
          domain = "${cfg.domainName}.${homelab.baseDomain}";
          http_addr = "127.0.0.1";
          http_port = cfg.port;
          root_url = "https://${cfg.domainName}.${homelab.baseDomain}/";
        };
      };
      provision.datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            url = "http://127.0.0.1:${toString homelab.prometheus.port}";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            uid = "loki";
            url = "http://127.0.0.1:${toString homelab.loki.port}";
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

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
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

        systemctl stop grafana-server.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start grafana-server.service
      '';
    };
  };
}
