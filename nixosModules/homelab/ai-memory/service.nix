{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.ai-memory;
  format = pkgs.formats.toml {};
  configFile = format.generate "ai-memory.toml" cfg.settings;
in {
  options.services.ai-memory = {
    enable = lib.mkEnableOption "ai-memory long-term memory server for AI agents";

    package = lib.mkPackageOption pkgs ["llm-agents" "ai-memory"] {};

    user = lib.mkOption {
      type = lib.types.str;
      default = "ai-memory";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "ai-memory";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/ai-memory";
      description = "Holds the git-backed markdown wiki (`wiki/`) and its derived SQLite index (`db/`).";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 49374;
    };

    enableWeb = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to serve the read-only web view of the wiki and its link graph.";
    };

    settings = lib.mkOption {
      type = format.type;
      default = {};
      description = ''
        ai-memory `config.toml`. It lands in the world-readable store, so keep
        secrets such as `AI_MEMORY_AUTH_TOKEN` in {option}`environmentFile`.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Environment file with secrets, such as `AI_MEMORY_AUTH_TOKEN`.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
      home = cfg.dataDir;
      description = "ai-memory service user";
    };
    users.groups.${cfg.group} = {};

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.ai-memory = {
      description = "ai-memory long-term memory server for AI agents";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      # hook capture and the wiki history shell out to git
      path = [pkgs.git];
      environment.HOME = cfg.dataDir;
      serviceConfig =
        {
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = cfg.dataDir;
          ExecStart = lib.escapeShellArgs (
            [
              (lib.getExe cfg.package)
              "--data-dir"
              cfg.dataDir
              "--config"
              configFile
              "serve"
              "--transport"
              "http"
              "--bind"
              "${cfg.host}:${toString cfg.port}"
            ]
            ++ lib.optional cfg.enableWeb "--enable-web"
          );
          Restart = "on-failure";
          RestartSec = 5;
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictSUIDSGID = true;
          RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
          CapabilityBoundingSet = "";
          LockPersonality = true;
          ReadWritePaths = [cfg.dataDir];
          UMask = "0077";
        }
        // lib.optionalAttrs (cfg.environmentFile != null) {
          EnvironmentFile = cfg.environmentFile;
        };
    };
  };
}
