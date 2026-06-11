{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.mosquitto;
  passwordGenerator = config.clan.core.vars.generators.mosquitto-passwords;
  passwordFile = user: passwordGenerator.files."${user}-password".path;
  mqttUsers = {
    elotoja = {
      acl = [
        "readwrite #"
        "readwrite $SYS/#"
      ];
    };
    zigbee2mqtt = {
      acl = [
        "readwrite zigbee2mqtt/#"
        "write homeassistant/#"
      ];
    };
    hass = {
      acl = [
        "readwrite #"
      ];
    };
  };
in {
  options.modules.homelab.mosquitto = {
    enable = lib.mkEnableOption "Enable Mosquitto MQTT broker";
    port = lib.mkOption {
      type = lib.types.port;
      default = 1883;
    };
    address = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "0.0.0.0";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}mosquitto";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      inherit (cfg) dataDir;
      listeners = [
        {
          inherit (cfg) address port;
          users =
            lib.mapAttrs
            (name: user: user // {passwordFile = passwordFile name;})
            mqttUsers;
          settings.allow_anonymous = false;
        }
      ];
    };
    clan.core.vars.generators.mosquitto-passwords = {
      files =
        lib.mapAttrs'
        (name: _: {
          name = "${name}-password";
          value = {
            owner = "root";
            group = "root";
          };
        })
        mqttUsers
        // {
          zigbee2mqtt-env = {
            owner = "root";
            group = "root";
          };
        };
      runtimeInputs = [pkgs.pwgen];
      script = ''
        mkdir -p "$out"
        elotoja_password=$(pwgen -s 64 1)
        zigbee2mqtt_password=$(pwgen -s 64 1)
        hass_password=$(pwgen -s 64 1)

        printf '%s\n' "$elotoja_password" > "$out/elotoja-password"
        printf '%s\n' "$zigbee2mqtt_password" > "$out/zigbee2mqtt-password"
        printf '%s\n' "$hass_password" > "$out/hass-password"
        printf 'ZIGBEE2MQTT_CONFIG_MQTT_PASSWORD=%s\n' "$zigbee2mqtt_password" > "$out/zigbee2mqtt-env"
      '';
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.port
    ];

    clan.core.state.mosquitto.folders = [
      cfg.dataDir
    ];
  };
}
