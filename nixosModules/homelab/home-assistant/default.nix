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
        homeassistant = let
          external_url = "https://${cfg.domainName}.${homelab.baseDomain}";
        in {
          name = "Home";
          unit_system = "metric";
          temperature_unit = "C";
          time_zone = timezone;
          inherit external_url;
          internal_url = external_url;
        };
        http = {
          server_host = "127.0.0.1";
          server_port = cfg.port;
          use_x_forwarded_for = true;
          trusted_proxies = ["127.0.0.1"];
        };
        default_config = {};
        mobile_app = {};
      };
      extraComponents = [
        # Components required to complete the onboarding
        "analytics"
        "google_translate"
        "met"
        # "radio_browser"
        "shopping_list"
        # Recommended for fast zlib compression
        # https://www.home-assistant.io/integrations/isal
        "isal"

        "mobile_app"

        # Devices
        "roomba"
        "xiaomi_miio"
        "home_connect"
        "samsungtv"
        "legrand"
        "netatmo"
        "bticino"

        "mqtt"

        "unifi"
        "unifi_discovery"

        # Homelab services
        "jellyfin"
        "sonarr"
        "radarr"
        "immich"
        "qbittorrent"
        "ntfy"
        "paperless_ngx"
        "uptime_kuma"
      ];
    };
    clan.core.state.home-assistant = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop home-assistant.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start home-assistant.service
      '';
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
        '';
      };
    };
  };
}
