{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "qbittorrent";
  domainName = "download";
  group = variables.homelab.groups.media;
  port = 8181;
  ns = config.services.wireguard-netns.namespace;
  dataDir = "${homelab.dataDir}${name}";
in {
  disabledModules = [
    "services/torrent/qbittorrent.nix"
  ];

  imports = [
    ./service.nix
    ./vuetorrent.nix
  ];
  services.qbittorrent = {
    enable = true;
    package = pkgs.unstable.qbittorrent-nox;
    user = name;
    inherit port group dataDir;
  };
  systemd =
    {
      services.qbittorrent.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
      tmpfiles.rules = [
        "d ${dataDir} 750 ${name} ${group} - -"
      ];
    }
    // (lib.mkIf config.services.wireguard-netns.enable {
      services.${name} = {
        bindsTo = ["netns@${ns}.service"];
        requires = [
          "network-online.target"
          "${ns}.service"
        ];
        serviceConfig.NetworkNamespacePath = ["/var/run/netns/${ns}"];
      };
      sockets."${name}-proxy" = {
        enable = true;
        description = "Socket for Proxy to ${name}";
        listenStreams = [(toString port)];
        wantedBy = ["sockets.target"];
      };
      services."${name}-proxy" = {
        enable = true;
        description = "Proxy to ${name} in Network Namespace";
        requires = [
          "${name}.service"
          "${name}-proxy.socket"
        ];
        after = [
          "${name}.service"
          "${name}-proxy.socket"
        ];
        unitConfig = {
          JoinsNamespaceOf = "${name}.service";
        };
        serviceConfig = {
          User = name;
          Group = group;
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString port}";
          PrivateNetwork = "yes";
        };
      };
    });

  services.vuetorrent = {
    enable = true;
    package = pkgs.unstable.vuetorrent;
  };

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  users.users.${name} = {
    inherit group;
    isSystemUser = true;
  };
}
