{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) stateVersion;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.immich;
in {
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
      default = "192.168.100.11";
    };
  };
  config = lib.mkIf cfg.enable {
    containers.immich = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = cfg.host;
      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";
      config = {
        services.immich = {
          inherit (cfg) group host port;
          enable = true;
          package = pkgs.unstable.immich;
          user = cfg.name;
          openFirewall = true;
          # accelerationDevices = ["/dev/dri/renderD128"];
          mediaLocation = cfg.dataDir;
          database = {
            inherit (cfg) name;
            enable = true;
            createDB = true;
            user = cfg.name;
          };
          redis = {
            enable = true;
            port = 0; # disable tcp
          };
          machine-learning.enable = true;
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
        services = {
          redis.package = pkgs.unstable.redis;
          postgresql.package = pkgs.unstable.postgresql;
          resolved.enable = true;
        };
        systemd.services.${cfg.name}.serviceConfig = {
          UMask = lib.mkForce homelab.defaultUMask;
        };
        systemd.tmpfiles.rules = [
          "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
        ];

        system.stateVersion = stateVersion;

        networking = {
          firewall.enable = true;
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        users.users.${cfg.name} = {
          isSystemUser = true;
          description = cfg.name;
          group = lib.mkForce cfg.group;
          # extraGroups = [
          #   "video"
          #   "render"
          # ];
        };
        users.groups = {
          ${homelab.groups.photos}.gid = 1102;
        };
      };
      forwardPorts = [
        {
          containerPort = cfg.port;
          hostPort = cfg.port;
          protocol = "tcp";
        }
      ];
      bindMounts.mediaLocation = {
        isReadOnly = false;
        hostPath = cfg.dataDir;
        mountPoint = cfg.dataDir;
      };
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://${cfg.host}:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
    clan.core.state.immich = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop container@immich.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start container@immich.service
      '';
    };

    # Enable NAT for the container
    networking.nat = {
      enable = true;
      # Use "ve-*" when using nftables instead of iptables
      internalInterfaces = ["ve-+"];
      externalInterface = "enp1s0";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };
  };
}
