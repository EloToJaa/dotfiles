{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.qbittorrent;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "qbittorrent";
    port = 8181;
    domainName = "qbit";
    glance.icon = "di:qbittorrent";
    gatus = {
      name = "qBittorrent";
      group = "media";
      path = "/api/v2/app/version";
      conditions = ["[STATUS] == any(200, 403)"];
    };
    forwardAuth = {};
  };
  ns = config.services.wireguard-netns.namespace;
in {
  options.modules.homelab.qbittorrent =
    service.options
    // {
      vuetorrent.enable = lib.mkEnableOption "Enable vuetorrent";
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.media;
      };
      exporterPort = lib.mkOption {
        type = lib.types.port;
        default = 9715;
        description = "Loopback port of the Prometheus exporter";
      };
    };
  disabledModules = [
    "services/torrent/qbittorrent.nix"
  ];
  imports = [
    ./exporter.nix
    ./service.nix
    ./vuetorrent.nix
  ];
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.qbittorrent = {
        enable = true;
        package = pkgs.unstable.qbittorrent-nox;
        user = cfg.name;
        inherit (cfg) port group dataDir;
      };
      systemd = lib.mkMerge [
        {
          services.qbittorrent.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
          tmpfiles.rules = [
            "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
          ];
        }
        (lib.mkIf config.services.wireguard-netns.enable {
          services.${cfg.name} = {
            bindsTo = ["netns@${ns}.service"];
            requires = [
              "network-online.target"
              "${ns}.service"
            ];
            serviceConfig.NetworkNamespacePath = ["/var/run/netns/${ns}"];
          };
          sockets."${cfg.name}-proxy" = {
            enable = true;
            description = "Socket for Proxy to ${cfg.name}";
            listenStreams = [(toString cfg.port)];
            wantedBy = ["sockets.target"];
          };
          services."${cfg.name}-proxy" = {
            enable = true;
            description = "Proxy to ${cfg.name} in Network Namespace";
            requires = ["${cfg.name}-proxy.socket"];
            after = [
              "${cfg.name}.service"
              "${cfg.name}-proxy.socket"
            ];
            unitConfig = {
              JoinsNamespaceOf = "${cfg.name}.service";
              Requisite = "${cfg.name}.service";
            };
            serviceConfig = {
              User = cfg.name;
              Group = cfg.group;
              ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString cfg.port}";
              PrivateNetwork = "yes";
            };
          };
        })
      ];

      clan.core.state.qbittorrent = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          ${lib.optionalString config.services.wireguard-netns.enable ''
            systemctl stop ${cfg.name}-proxy.socket
            systemctl stop ${cfg.name}-proxy.service
          ''}
          systemctl stop ${cfg.name}.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start ${cfg.name}.service
          ${lib.optionalString config.services.wireguard-netns.enable ''
            systemctl start ${cfg.name}-proxy.socket
          ''}
        '';
      };

      services.vuetorrent = {
        inherit (cfg.vuetorrent) enable;
        package = pkgs.unstable.vuetorrent;
      };

      users.users.${cfg.name} = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    })
  ];
}
