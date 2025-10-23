{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) timezone;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.home-assistant;
in {
  options.modules.homelab.home-assistant = {
    enable = lib.mkEnableOption "Enable Home Assistant";
    name = lib.mkOption {
      type = lib.types.str;
      default = "hass";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "hass";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8123;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      package = pkgs.unstable.home-assistant.overrideAttrs (_: {
        doInstallCheck = false;
      });
      configDir = cfg.dataDir;
      configWritable = true;
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          temperature_unit = "C";
          time_zone = timezone;
        };
        http = {
          server_host = "127.0.0.1";
          server_port = cfg.port;
          use_x_forwarded_for = true;
          trusted_proxies = ["127.0.0.1"];
        };
      };
      extraComponents = [
        # Components required to complete the onboarding
        "analytics"
        "google_translate"
        "met"
        "radio_browser"
        "shopping_list"
        # Recommended for fast zlib compression
        # https://www.home-assistant.io/integrations/isal
        "isal"

        "roomba"
        "xiaomi_miio"
      ];
    };
    services.restic.backups.appdata-local.paths = [
      cfg.dataDir
    ];

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
