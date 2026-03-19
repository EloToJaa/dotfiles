{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.services.zeroclaw;

  configFile = pkgs.writeText "zeroclaw-config.toml" (inputs.self.lib.toTOML (cfg.config
    // {
      gateway = {
        inherit (cfg) host port;
        allow_public_bind = false;
      };
    }));
in {
  options.services.zeroclaw = {
    enable = lib.mkEnableOption "zeroclaw AI assistant runtime";
    package = lib.mkPackageOption pkgs "zeroclaw" {};
    user = lib.mkOption {
      type = lib.types.str;
      default = "zeroclaw";
      description = "User account under which zeroclaw runs.";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "zeroclaw";
      description = "Group under which zeroclaw runs.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 42617;
      description = "Port for zeroclaw gateway.";
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address for zeroclaw gateway.";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/zeroclaw";
      description = "Directory where zeroclaw stores its configuration and data.";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall port for zeroclaw gateway.";
    };
    config = lib.mkOption {
      type = with lib.types; attrsOf (oneOf [str int bool (attrsOf anything)]);
      default = {};
      description = "Configuration options for zeroclaw config.toml. See https://github.com/zeroclaw-labs/zeroclaw for available options.";
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to environment file with API_KEY and DATABASE_URL.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.zeroclaw = {
      description = "ZeroClaw AI assistant runtime";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/zeroclaw --config-dir ${cfg.dataDir} daemon";
        WorkingDirectory = cfg.dataDir;
        Restart = "always";
        RestartSec = "5";

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [cfg.dataDir];

        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
      };

      # Copy generated config to data directory on start
      preStart = ''
        mkdir -p ${cfg.dataDir}
        cp ${configFile} ${cfg.dataDir}/config.toml
        chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
        chmod 750 ${cfg.dataDir}
      '';
    };

    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
      description = "zeroclaw service user";
      home = cfg.dataDir;
    };
    users.groups.${cfg.group} = {};

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };
  };
}
