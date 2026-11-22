{
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab.wireguard;
  exporter = config.services.prometheus.exporters.wireguard;
  ns = config.services.wireguard-netns.namespace;
in {
  options.modules.homelab.wireguard = {
    enable = lib.mkEnableOption "Enable wireguard";
    name = lib.mkOption {
      type = lib.types.str;
      default = "wireguard";
    };
    privateIP = lib.mkOption {
      type = lib.types.str;
      default = "10.71.102.82";
    };
    dnsIP = lib.mkOption {
      type = lib.types.str;
      default = "10.64.0.1";
    };
  };
  # Device: Sharp Hare
  # Server: ch-zrh-wg-003
  imports = [
    ./service.nix
  ];
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.wireguard = {
      enable = true;
      listenAddress = "127.0.0.1";
    };

    modules.homelab.prometheus.scrapeTargets = [
      {
        job_name = "wireguard";
        address = "127.0.0.1:${toString exporter.port}";
      }
    ];

    systemd.services.prometheus-wireguard-exporter = {
      bindsTo = ["netns@${ns}.service"];
      requires = [
        "network-online.target"
        "${ns}.service"
      ];
      after = ["${ns}.service"];
      serviceConfig.NetworkNamespacePath = ["/var/run/netns/${ns}"];
    };

    systemd.sockets.prometheus-wireguard-exporter-proxy = {
      description = "Socket for proxy to the WireGuard exporter in the network namespace";
      listenStreams = ["127.0.0.1:${toString exporter.port}"];
      wantedBy = ["sockets.target"];
    };
    systemd.services.prometheus-wireguard-exporter-proxy = {
      description = "Proxy to the WireGuard exporter in the network namespace";
      requires = ["prometheus-wireguard-exporter-proxy.socket"];
      after = [
        "prometheus-wireguard-exporter.service"
        "prometheus-wireguard-exporter-proxy.socket"
      ];
      unitConfig = {
        JoinsNamespaceOf = "prometheus-wireguard-exporter.service";
        Requisite = "prometheus-wireguard-exporter.service";
      };
      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString exporter.port}";
        PrivateNetwork = "yes";
      };
    };

    services."wireguard-netns" = {
      enable = true;
      configFile = config.clan.core.vars.generators."${cfg.name}-config".files."wg0.conf".path;
      inherit (cfg) privateIP dnsIP;
    };

    clan.core.vars.generators.${cfg.name} = {
      prompts = {
        privatekey = {
          description = "WireGuard client private key";
          type = "hidden";
          persist = true;
        };
        publickey = {
          description = "WireGuard server public key";
          type = "hidden";
          persist = true;
        };
        endpoint = {
          description = "WireGuard server IP address";
          type = "hidden";
          persist = true;
        };
      };
      files = {
        privatekey.deploy = false;
        publickey.deploy = false;
        endpoint.deploy = false;
      };
    };
    clan.core.vars.generators."${cfg.name}-config" = {
      dependencies = [cfg.name];
      files."wg0.conf" = {};
      script = ''
        printf '[Interface]\nPrivateKey = %s\n\n[Peer]\nPublicKey = %s\nAllowedIPs = 0.0.0.0/0\nEndpoint = %s:51820\n' \
          "$(cat "$in/${cfg.name}/privatekey")" \
          "$(cat "$in/${cfg.name}/publickey")" \
          "$(cat "$in/${cfg.name}/endpoint")" \
          > "$out/wg0.conf"
      '';
    };
  };
}
