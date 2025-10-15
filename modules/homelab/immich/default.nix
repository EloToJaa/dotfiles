{
  pkgs,
  config,
  lib,
  variables,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.immich;
in {
  options.modules.homelab.immich = {
    enable = lib.mkEnableOption "Immich module";
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
    dbPort = lib.mkOption {
      type = lib.types.port;
      default = 5433;
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/Photos";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}nixos-containers/${cfg.name}${homelab.varDataDir}";
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
          mediaLocation = "/data";
          database = {
            inherit (cfg) name;
            enable = true;
            createDB = true;
            port = cfg.dbPort;
            user = cfg.name;
          };
          redis = {
            enable = true;
            port = 0; # disable tcp
          };
          machine-learning = {
            enable = true;
          };
          settings = {
            newVersionCheck.enabled = true;
            server.externalDomain = "https://${cfg.domainName}.${homelab.baseDomain}";
          };
        };
        services.redis.package = pkgs.unstable.redis;
        systemd.services.${cfg.name}.serviceConfig = {
          UMask = lib.mkForce homelab.defaultUMask;
        };
        systemd.tmpfiles.rules = [
          "d ${homelab.varDataDir}${cfg.name} 750 ${cfg.name} ${cfg.group} - -"
        ];

        system.stateVersion = variables.stateVersion;

        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [5433];
          };
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;

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
          containerPort = cfg.dbPort;
          hostPort = cfg.dbPort;
          protocol = "tcp";
        }
        {
          containerPort = cfg.port;
          hostPort = cfg.port;
          protocol = "tcp";
        }
      ];
      bindMounts.mediaLocation = {
        isReadOnly = false;
        hostPath = cfg.mediaDir;
        mountPoint = "/data";
      };
    };

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${cfg.host}:${toString cfg.port}
      '';
    };
    services.restic.backups.appdata-local.paths = [
      cfg.dataDir
      cfg.mediaDir
    ];
    networking.firewall.allowedTCPPorts = [cfg.dbPort];
  };
}
