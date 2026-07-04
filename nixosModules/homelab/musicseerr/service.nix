{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.musicseerr;
in {
  options.services.musicseerr = {
    enable = lib.mkEnableOption "MusicSeerr, a music request and discovery app built around Lidarr";

    package = lib.mkPackageOption pkgs "musicseerr" {};

    user = lib.mkOption {
      type = lib.types.str;
      default = "musicseerr";
      description = "User account under which MusicSeerr runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "musicseerr";
      description = "Group account under which MusicSeerr runs.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8688;
      description = "Port for the MusicSeerr web interface.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/musicseerr";
      description = "Directory used for MusicSeerr configuration and cache state.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the MusicSeerr web interface port in the firewall.";
    };

    environment = lib.mkOption {
      type = with lib.types; attrsOf (oneOf [str int bool path]);
      default = {};
      description = "Additional environment variables passed to MusicSeerr.";
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Optional environment file passed to MusicSeerr.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.musicseerr = {
      description = "MusicSeerr music request and discovery app";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      environment =
        {
          PORT = toString cfg.port;
          ROOT_APP_DIR = cfg.dataDir;
          CACHE_DIR = "${cfg.dataDir}/cache";
          CONFIG_FILE_PATH = "${cfg.dataDir}/config/config.json";
        }
        // lib.mapAttrs (_: toString) cfg.environment;

      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = lib.getExe cfg.package;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        Restart = "on-failure";
        RestartSec = 5;
        StateDirectory = "musicseerr";
        StateDirectoryMode = "0750";
        WorkingDirectory = cfg.dataDir;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [cfg.dataDir];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/cache 750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/config 750 ${cfg.user} ${cfg.group} - -"
    ];

    users.users.${cfg.user} = {
      inherit (cfg) group;
      description = cfg.user;
      home = cfg.dataDir;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = {};

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };
  };
}
