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
  usersWithEnv = lib.filterAttrs (_: user: user.environment != []) cfg.users;
  shellPasswordVar = name: "$" + name + "_password";
  passwordScript = name: _: ''
    ${name}_password=$(pwgen -s 64 1)
    printf '%s\n' "${shellPasswordVar name}" > "$out/${name}-password"
  '';
  envScript = name: user: ''
    {
      ${lib.concatStringsSep "\n" (
      map
      (variable: ''printf '${variable}=%s\n' "${shellPasswordVar name}"'')
      user.environment
    )}
    } > "$out/${name}-env"
  '';
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
    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          acl = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
          };
          environment = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
          };
        };
      });
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    modules.homelab.mosquitto.users.elotoja.acl = lib.mkDefault [
      "readwrite #"
      "readwrite $SYS/#"
    ];
    services.mosquitto = {
      enable = true;
      package = pkgs.unstable.mosquitto;
      inherit (cfg) dataDir;
      listeners = [
        {
          inherit (cfg) address port;
          users =
            lib.mapAttrs
            (name: user: {
              inherit (user) acl;
              passwordFile = passwordFile name;
            })
            cfg.users;
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
        // lib.mapAttrs'
        (name: _: {
          name = "${name}-env";
          value = {
            owner = "root";
            group = "root";
          };
        })
        usersWithEnv;
      runtimeInputs = [pkgs.pwgen];
      script = ''
        mkdir -p "$out"
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList passwordScript mqttUsers)}
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList envScript usersWithEnv)}
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
