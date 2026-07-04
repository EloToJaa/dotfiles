{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.prowlarr;
  ns = config.services.wireguard-netns.namespace;
  postgresHost =
    if config.services.wireguard-netns.enable
    then config.services.wireguard-netns.hostAddress
    else "127.0.0.1";
in {
  options.modules.homelab.prowlarr = {
    enable = lib.mkEnableOption "Enable prowlarr";
    name = lib.mkOption {
      type = lib.types.str;
      default = "prowlarr";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "prowlarr";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9696;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  disabledModules = [
    "services/misc/servarr/prowlarr.nix"
  ];
  imports = [
    ./service.nix
    ./flaresolverr.nix
  ];
  config = lib.mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
      package = pkgs.unstable.prowlarr;
      user = cfg.name;
      inherit (cfg) group dataDir;
    };

    systemd =
      {
        services.${cfg.name}.serviceConfig = {
          UMask = lib.mkForce homelab.defaultUMask;
        };
        tmpfiles.rules = [
          "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
        ];
      }
      // (lib.mkIf config.services.wireguard-netns.enable {
        services =
          {
            ${cfg.name} = {
              bindsTo = ["netns@${ns}.service"];
              requires = [
                "network-online.target"
                "${ns}.service"
              ];
              serviceConfig.NetworkNamespacePath = ["/var/run/netns/${ns}"];
            };
            "${cfg.name}-proxy" = {
              enable = true;
              description = "Proxy to ${cfg.name} in Network Namespace";
              requires = [
                "${cfg.name}.service"
                "${cfg.name}-proxy.socket"
              ];
              after = [
                "${cfg.name}.service"
                "${cfg.name}-proxy.socket"
              ];
              unitConfig = {
                JoinsNamespaceOf = "${cfg.name}.service";
              };
              serviceConfig = {
                User = cfg.name;
                Group = cfg.group;
                ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString cfg.port}";
                PrivateNetwork = "yes";
              };
            };
          }
          // lib.optionalAttrs homelab.radarr.enable {
            "${cfg.name}-radarr-proxy" = {
              enable = true;
              description = "Proxy from ${cfg.name} namespace to radarr";
              requires = ["${cfg.name}-radarr-proxy.socket"];
              after = ["${cfg.name}-radarr-proxy.socket"];
              serviceConfig.ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString homelab.radarr.port}";
            };
          }
          // lib.optionalAttrs homelab.sonarr.enable {
            "${cfg.name}-sonarr-proxy" = {
              enable = true;
              description = "Proxy from ${cfg.name} namespace to sonarr";
              requires = ["${cfg.name}-sonarr-proxy.socket"];
              after = ["${cfg.name}-sonarr-proxy.socket"];
              serviceConfig.ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString homelab.sonarr.port}";
            };
          }
          // lib.optionalAttrs homelab.lidarr.enable {
            "${cfg.name}-lidarr-proxy" = {
              enable = true;
              description = "Proxy from ${cfg.name} namespace to lidarr";
              requires = ["${cfg.name}-lidarr-proxy.socket"];
              after = ["${cfg.name}-lidarr-proxy.socket"];
              serviceConfig.ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString homelab.lidarr.port}";
            };
          };
        sockets =
          {
            "${cfg.name}-proxy" = {
              enable = true;
              description = "Socket for Proxy to ${cfg.name}";
              listenStreams = [(toString cfg.port)];
              wantedBy = ["sockets.target"];
            };
          }
          // lib.optionalAttrs homelab.radarr.enable {
            "${cfg.name}-radarr-proxy" = {
              enable = true;
              description = "Socket for ${cfg.name} namespace access to radarr";
              listenStreams = ["${config.services.wireguard-netns.hostAddress}:${toString homelab.radarr.port}"];
              wantedBy = ["sockets.target"];
              socketConfig.FreeBind = true;
            };
          }
          // lib.optionalAttrs homelab.sonarr.enable {
            "${cfg.name}-sonarr-proxy" = {
              enable = true;
              description = "Socket for ${cfg.name} namespace access to sonarr";
              listenStreams = ["${config.services.wireguard-netns.hostAddress}:${toString homelab.sonarr.port}"];
              wantedBy = ["sockets.target"];
              socketConfig.FreeBind = true;
            };
          }
          // lib.optionalAttrs homelab.lidarr.enable {
            "${cfg.name}-lidarr-proxy" = {
              enable = true;
              description = "Socket for ${cfg.name} namespace access to lidarr";
              listenStreams = ["${config.services.wireguard-netns.hostAddress}:${toString homelab.lidarr.port}"];
              wantedBy = ["sockets.target"];
              socketConfig.FreeBind = true;
            };
          };
      });

    networking.firewall.interfaces.wg-host.allowedTCPPorts = lib.mkIf config.services.wireguard-netns.enable (
      lib.optionals homelab.radarr.enable [homelab.radarr.port]
      ++ lib.optionals homelab.sonarr.enable [homelab.sonarr.port]
      ++ lib.optionals homelab.lidarr.enable [homelab.lidarr.port]
    );

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    services.postgresql.authentication = lib.mkIf config.services.wireguard-netns.enable ''
      host ${cfg.name}-main,${cfg.name}-log ${cfg.name} ${config.services.wireguard-netns.namespaceVethAddress} md5
    '';

    clan.core.postgresql = {
      databases = {
        "${cfg.name}-main" = {
          create = {
            enable = true;
            options = {
              LC_COLLATE = "C";
              LC_CTYPE = "C";
              ENCODING = "UTF8";
              OWNER = cfg.name;
              TEMPLATE = "template0";
            };
          };
          restore.stopOnRestore = ["prowlarr.service"];
        };
        "${cfg.name}-log" = {
          create = {
            enable = true;
            options = {
              LC_COLLATE = "C";
              LC_CTYPE = "C";
              ENCODING = "UTF8";
              OWNER = cfg.name;
              TEMPLATE = "template0";
            };
          };
          restore.stopOnRestore = ["prowlarr.service"];
        };
      };
      users.${cfg.name} = {};
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };

    sops.secrets = {
      "${cfg.name}/apikey" = {
        owner = cfg.name;
      };
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
    sops.templates."config-${cfg.name}.xml" = {
      restartUnits = ["prowlarr.service"];
      content = ''
        <Config>
          <LogLevel>info</LogLevel>
          <EnableSsl>False</EnableSsl>
          <Port>${toString cfg.port}</Port>
          <SslPort>6969</SslPort>
          <UrlBase></UrlBase>
          <BindAddress>127.0.0.1</BindAddress>
          <ApiKey>${config.sops.placeholder."${cfg.name}/apikey"}</ApiKey>
          <AuthenticationMethod>Forms</AuthenticationMethod>
          <LaunchBrowser>True</LaunchBrowser>
          <Branch>master</Branch>
          <InstanceName>Prowlarr</InstanceName>
          <AuthenticationRequired>Enabled</AuthenticationRequired>
          <SslCertPath></SslCertPath>
          <SslCertPassword></SslCertPassword>
          <PostgresUser>${cfg.name}</PostgresUser>
          <PostgresPassword>${config.sops.placeholder."${cfg.name}/pgpassword"}</PostgresPassword>
          <PostgresPort>${toString homelab.postgres.port}</PostgresPort>
          <PostgresHost>${postgresHost}</PostgresHost>
          <AnalyticsEnabled>False</AnalyticsEnabled>
          <Theme>auto</Theme>
        </Config>
      '';
      path = "${cfg.dataDir}/config.xml";
      owner = cfg.name;
    };
  };
}
