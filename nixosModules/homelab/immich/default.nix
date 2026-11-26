{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.immich;
  immich_services = [
    "immich-server.service"
    "immich-machine-learning.service"
  ];
in {
  imports = [
    ./auth.nix
  ];

  options.modules.homelab.immich = {
    enable = lib.mkEnableOption "Enable immich";
    name = lib.mkOption {
      type = lib.types.str;
      default = "immich";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "photos";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.photos;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 2283;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };
    apiMetricsPort = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port of the Immich API telemetry endpoint";
    };
    microservicesMetricsPort = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Port of the Immich microservices telemetry endpoint";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = homelab.postgres.enable;
        message = "modules.homelab.immich requires modules.homelab.postgres";
      }
    ];

    modules.homelab.glance.sites = [
      {
        title = "Immich";
        group = "apps";
        url = "https://${cfg.domainName}.${homelab.baseDomain}";
        checkUrl = "https://${cfg.domainName}.${homelab.baseDomain}/api/server/ping";
        icon = "di:immich";
      }
    ];

    modules.homelab.gatus.endpoints = [
      {
        name = "Immich";
        group = "apps";
        url = "https://${cfg.domainName}.${homelab.baseDomain}/api/server/ping";
        conditions = ["[STATUS] == 200"];
      }
    ];

    modules.homelab.prometheus.scrapeTargets = [
      {
        job_name = "immich-api";
        address = "${cfg.host}:${toString cfg.apiMetricsPort}";
      }
      {
        job_name = "immich-microservices";
        address = "${cfg.host}:${toString cfg.microservicesMetricsPort}";
      }
    ];

    services.immich = {
      inherit (cfg) group host port;
      enable = true;
      package = pkgs.unstable.immich;
      user = cfg.name;
      mediaLocation = cfg.dataDir;
      database = {
        inherit (cfg) name;
        enable = true;
        createDB = false;
        user = cfg.name;
      };
      redis = {
        enable = true;
        port = 0; # disable tcp
      };
      machine-learning.enable = true;
      environment = {
        IMMICH_TELEMETRY_INCLUDE = "all";
        IMMICH_API_METRICS_PORT = toString cfg.apiMetricsPort;
        IMMICH_MICROSERVICES_METRICS_PORT = toString cfg.microservicesMetricsPort;
      };
      settings = {
        newVersionCheck.enabled = false;
        server.externalDomain = "https://${cfg.domainName}.${homelab.baseDomain}";
        backup = {
          enabled = true;
          cronExpression = "0 02 * * *";
          keepLastAmount = 14;
        };
        metadata.faces.import = true;
        user.deleteDelay = 14;
        trash = {
          enabled = true;
          days = 30;
        };
      };
    };

    systemd.services.immich-server.serviceConfig = {
      UMask = lib.mkForce homelab.defaultUMask;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://${cfg.host}:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_request_buffering off;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
      extraConfig = ''
        client_max_body_size 50G;
      '';
    };

    clan.core.postgresql = {
      databases.${cfg.name} = {
        create.options.OWNER = cfg.name;
        restore.stopOnRestore = immich_services;
      };
      users.${cfg.name} = {};
    };

    clan.core.state.${cfg.name} = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop ${toString immich_services}
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start ${toString immich_services}
      '';
    };
  };
}
