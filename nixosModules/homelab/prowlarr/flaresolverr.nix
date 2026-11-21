{
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab.prowlarr.flaresolverr;
  ns = config.services.wireguard-netns.namespace;
in {
  options.modules.homelab.prowlarr.flaresolverr = {
    enable = lib.mkEnableOption "Enable flaresolverr";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8191;
    };
  };
  config = lib.mkIf cfg.enable {
    services.flaresolverr = {
      enable = true;
      inherit (cfg) port;
    };
    systemd.services.flaresolverr = lib.mkMerge [
      {environment.HOST = "127.0.0.1";}
      (lib.mkIf config.services.wireguard-netns.enable {
        bindsTo = ["netns@${ns}.service"];
        requires = [
          "network-online.target"
          "${ns}.service"
        ];
        serviceConfig.NetworkNamespacePath = ["/var/run/netns/${ns}"];
      })
    ];
  };
}
