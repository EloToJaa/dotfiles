{
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.mosquitto;
in {
  options.modules.homelab.mosquitto = {
    enable = lib.mkEnableOption "Enable Mosquitto MQTT broker";
    port = lib.mkOption {
      type = lib.types.port;
      default = 1883;
    };
    address = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "127.0.0.1";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}mosquitto";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      dataDir = cfg.dataDir;
      listeners = [
        {
          inherit (cfg) address port;
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.port
    ];

    clan.core.state.mosquitto.folders = [
      cfg.dataDir
    ];
  };
}
