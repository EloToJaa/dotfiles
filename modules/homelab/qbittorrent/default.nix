{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.qbittorrent;
  ns = config.services.wireguard-netns.namespace;
in {
  options.modules.homelab.qbittorrent = {
    enable = lib.mkEnableOption "Enable qbittorrent";
    vuetorrent.enable = lib.mkEnableOption "Enable vuetorrent";
    name = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "download";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.media;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8181;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}${cfg.name}";
    };
  };
  disabledModules = [
    "services/torrent/qbittorrent.nix"
  ];
  imports = [
    ./service.nix
    ./vuetorrent.nix
  ];
  config = lib.mkIf cfg.enable {
    services.qbittorrent = {
      enable = true;
      package = pkgs.unstable.qbittorrent-nox;
      user = cfg.name;
      inherit (cfg) port group dataDir;
    };
    systemd =
      {
        services.qbittorrent.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
        tmpfiles.rules = [
          "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
        ];
      }
      // (lib.mkIf config.services.wireguard-netns.enable {
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
          requires = [
            "${cfg.name}.service"
            "${cfg.name}-proxy.socket"
          ];
          after = [
            "${cfg.name}.service"
            "${cfg.name}-proxy.socket"
          ];
          unitConfig = {
            JoinsNamespcfg.aceOf = "${cfg.name}.service";
          };
          serviceConfig = {
            User = cfg.name;
            Group = cfg.group;
            ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString cfg.port}";
            PrivateNetwork = "yes";
          };
        };
      });

    services.vuetorrent = {
      enable = cfg.vuetorrent.enable;
      package = pkgs.unstable.vuetorrent;
    };

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    users.users.${cfg.name} = {
      inherit (cfg) group;
      isSystemUser = true;
    };
  };
}
