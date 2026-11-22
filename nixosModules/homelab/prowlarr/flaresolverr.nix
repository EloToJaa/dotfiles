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
  };
}
