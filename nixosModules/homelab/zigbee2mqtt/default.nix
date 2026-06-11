{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.zigbee2mqtt;
  mqtt = config.modules.homelab.mosquitto;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.zigbee2mqtt = {
    enable = lib.mkEnableOption "Enable Zigbee2MQTT";
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "zigbee";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3007;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}zigbee2mqtt";
    };
    serialPort = lib.mkOption {
      type = lib.types.str;
      default = "tcp://10.11.0.35:1234";
    };
    permitJoin = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    baseTopic = lib.mkOption {
      type = lib.types.str;
      default = "zigbee2mqtt";
    };
    mqttServer = lib.mkOption {
      type = lib.types.str;
      default = "mqtt://127.0.0.1:${toString mqtt.port}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.zigbee2mqtt = {
      enable = true;
      package = pkgs.unstable.zigbee2mqtt;
      inherit (cfg) dataDir;
      settings = {
        homeassistant.enabled = config.services.home-assistant.enable;
        permit_join = cfg.permitJoin;
        availability.enabled = true;
        mqtt = {
          base_topic = cfg.baseTopic;
          server = cfg.mqttServer;
          user = "zigbee2mqtt";
        };
        serial = {
          port = cfg.serialPort;
          adapter = "zstack";
        };
        frontend = {
          enabled = true;
          host = "127.0.0.1";
          inherit (cfg) port;
          url = "https://${domain}";
          package = "zigbee2mqtt-windfront";
        };
      };
    };

    systemd.services.zigbee2mqtt = lib.mkIf mqtt.enable {
      after = ["mosquitto.service"];
      wants = ["mosquitto.service"];
      serviceConfig.EnvironmentFile =
        config.clan.core.vars.generators.mosquitto-passwords.files.zigbee2mqtt-env.path;
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    clan.core.state.zigbee2mqtt.folders = [
      cfg.dataDir
    ];
  };
}
