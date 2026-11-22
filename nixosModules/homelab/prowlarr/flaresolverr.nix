{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.homelab.prowlarr.flaresolverr;
  ns = config.services.wireguard-netns.namespace;
  fontsConf = pkgs.makeFontsConf {
    fontDirectories = with pkgs; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
    ];
  };
in {
  options.modules.homelab.prowlarr.flaresolverr = {
    enable = lib.mkEnableOption "Enable flaresolverr";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8191;
    };
  };
  config = lib.mkIf cfg.enable {
    modules.homelab.gatus.endpoints = [
      {
        name = "FlareSolverr";
        group = "media";
        url = "http://127.0.0.1:${toString cfg.port}/health";
        conditions = [
          "[STATUS] == 200"
          "[BODY].status == ok"
        ];
      }
    ];

    services.flaresolverr = {
      enable = true;
      package = pkgs.unstable.flaresolverr;
      inherit (cfg) port;
    };
    systemd.services.flaresolverr = lib.mkMerge [
      {
        environment = {
          HOST = "127.0.0.1";
          # Headless Chromium aborts while enumerating fonts when fontconfig is disabled system-wide.
          FONTCONFIG_FILE = fontsConf;
        };
      }
      (lib.mkIf config.services.wireguard-netns.enable {
        bindsTo = ["netns@${ns}.service"];
        requires = [
          "network-online.target"
          "${ns}.service"
        ];
        serviceConfig.NetworkNamespacePath = ["/var/run/netns/${ns}"];
      })
    ];

    systemd.services.flaresolverr-proxy = lib.mkIf config.services.wireguard-netns.enable {
      description = "Proxy to flaresolverr in Network Namespace";
      requires = ["flaresolverr-proxy.socket"];
      after = [
        "flaresolverr.service"
        "flaresolverr-proxy.socket"
      ];
      unitConfig = {
        JoinsNamespaceOf = "flaresolverr.service";
        Requisite = "flaresolverr.service";
      };
      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString cfg.port}";
        PrivateNetwork = "yes";
      };
    };
    systemd.sockets.flaresolverr-proxy = lib.mkIf config.services.wireguard-netns.enable {
      description = "Socket for Proxy to flaresolverr";
      listenStreams = ["127.0.0.1:${toString cfg.port}"];
      wantedBy = ["sockets.target"];
    };
  };
}
