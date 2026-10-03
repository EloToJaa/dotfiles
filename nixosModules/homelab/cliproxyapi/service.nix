{
  lib,
  config,
  pkgs,
  utils,
  ...
}: let
  cfg = config.services.cliproxyapi;
  format = pkgs.formats.yaml {};
  configPath = "${cfg.dataDir}/config.yaml";
  secretsReplacement = utils.genJqSecretsReplacement {loadCredential = true;} cfg.settings configPath;
in {
  disabledModules = ["services/misc/cliproxyapi.nix"];

  options.services.cliproxyapi = {
    enable = lib.mkEnableOption "CLIProxyAPI";

    package = lib.mkPackageOption pkgs ["llm-agents" "cli-proxy-api"] {};

    user = lib.mkOption {
      type = lib.types.str;
      default = "cliproxyapi";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "cliproxyapi";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/cliproxyapi";
      description = "Directory for OAuth credentials and writable runtime configuration.";
    };

    settings = lib.mkOption {
      type = format.type;
      default = {};
      description = ''
        CLIProxyAPI v8 configuration. Secret values can be loaded with
        { _secret = "/run/secrets/key"; }. The runtime configuration is
        regenerated on service start; management API configuration edits
        should also be applied here to persist across restarts.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Environment file containing optional provider or proxy credentials.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the configured server port.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.cliproxyapi.settings = {
      config-version = lib.mkDefault 8;
      server.host = lib.mkDefault "127.0.0.1";
      server.port = lib.mkDefault 8317;
      oauth.auth-dir = lib.mkDefault "${cfg.dataDir}/auth";
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
      home = cfg.dataDir;
      description = "CLIProxyAPI service user";
    };
    users.groups.${cfg.group} = {};

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.cliproxyapi = {
      description = "CLIProxyAPI AI provider proxy";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      preStart = secretsReplacement.script;
      serviceConfig =
        {
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = cfg.dataDir;
          ExecStart = "${lib.getExe cfg.package} -config ${lib.escapeShellArg configPath}";
          Restart = "on-failure";
          RestartSec = 5;
          LoadCredential = secretsReplacement.credentials;
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictSUIDSGID = true;
          ReadWritePaths = [cfg.dataDir];
          UMask = "0077";
        }
        // lib.optionalAttrs (cfg.environmentFile != null) {
          EnvironmentFile = cfg.environmentFile;
        };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.settings.server.port];
    };
  };
}
