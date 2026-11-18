{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.ai-memory;
  secrets = config.clan.core.vars.generators.ai-memory-server;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  # non-secret settings only; the bearer token comes from the env file
  configFile = (pkgs.formats.toml {}).generate "ai-memory.toml" {
    allowed_hosts = [domain "localhost" "127.0.0.1" "::1"];
    log_level = "info";
  };
in {
  options.modules.homelab.ai-memory = {
    enable = lib.mkEnableOption "Enable ai-memory, the shared long-term memory server for AI agents";

    name = lib.mkOption {
      type = lib.types.str;
      default = "ai-memory";
    };

    domainName = lib.mkOption {
      type = lib.types.str;
      default = "memory";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 49374;
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
      description = "Holds the git-backed markdown wiki (`wiki/`) and its derived SQLite index (`db/`).";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users.${cfg.name} = {
        isSystemUser = true;
        group = cfg.name;
        home = cfg.dataDir;
      };
      groups.${cfg.name} = {};
    };

    systemd.services.ai-memory = {
      description = "ai-memory long-term memory server for AI agents";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      # hook capture and the wiki history shell out to git
      path = [pkgs.git];
      environment.HOME = cfg.dataDir;
      serviceConfig = {
        ExecStart = lib.escapeShellArgs [
          (lib.getExe pkgs.llm-agents.ai-memory)
          "--data-dir"
          cfg.dataDir
          "--config"
          configFile
          "serve"
          "--transport"
          "http"
          "--bind"
          "127.0.0.1:${toString cfg.port}"
          "--enable-web"
        ];
        EnvironmentFile = secrets.files.env.path;
        User = cfg.name;
        Group = cfg.name;
        Restart = "on-failure";
        RestartSec = 5;
        UMask = "0077";
        StateDirectory = cfg.name;
        StateDirectoryMode = "0700";
        WorkingDirectory = cfg.dataDir;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        CapabilityBoundingSet = "";
        LockPersonality = true;
      };
    };

    clan.core.vars.generators.ai-memory-server = {
      share = true;
      dependencies = ["ai-memory"];
      files.env = {
        owner = cfg.name;
        group = cfg.name;
      };
      script = ''
        printf 'AI_MEMORY_AUTH_TOKEN=%s\n' "$(cat "$in/ai-memory/auth-token")" > "$out/env"
      '';
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 600s;
          client_max_body_size 64m;
        '';
      };
    };

    clan.core.state.ai-memory = {
      folders = [cfg.dataDir];
      preBackupScript = ''
        ${config.systemd.package}/bin/systemctl stop ai-memory.service
      '';
      postBackupScript = ''
        ${config.systemd.package}/bin/systemctl start ai-memory.service
      '';
    };
  };
}
