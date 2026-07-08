{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (config.settings) username;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.hermes;
in {
  options.modules.homelab.hermes = {
    enable = lib.mkEnableOption "Enable hermes";
    name = lib.mkOption {
      type = lib.types.str;
      default = "hermes";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "hermes";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8642;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.hermes-agent = {
      # package = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.messaging;
      enable = true;
      addToSystemPackages = true;
      stateDir = cfg.dataDir;
      environmentFiles = [config.sops.templates."${cfg.name}.env".path];

      extraDependencyGroups = [
        "messaging"
        "firecrawl"
      ];
      extraPythonPackages = [
        pkgs.python3Packages.ddgs
      ];

      container = {
        enable = true;
        backend = "podman";
        hostUsers = [username];
        image = "ubuntu:24.04";
      };

      workingDirectory = "${cfg.dataDir}/workspace";

      settings = {
        # terminal.cwd = "/data/workspace";
        model = {
          provider = "openai-codex";
          default = "gpt-5.5";
        };
        web = {
          search_backend = "ddgs";
          extract_backend = "firecrawl";
        };
      };
      environment = {
        DISCORD_ALLOWED_USERS = "308939544407834625";
        # Hermes v0.16 emits a /skill slash-command payload over Discord's
        # 8000-byte limit. Plain text commands still work; don't sync invalid
        # native slash commands at startup.
        # DISCORD_COMMAND_SYNC_POLICY = "off";
        API_SERVER_ENABLED = "true";
        API_SERVER_PORT = toString cfg.port;
        API_SERVER_HOST = "127.0.0.1";
      };
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    clan.core.state.hermes-agent = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop hermes-agent.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start hermes-agent.service
      '';
    };

    sops.secrets = {
      "${cfg.name}/opencode-api-key" = {
        group = cfg.name;
      };
      "${cfg.name}/firecrawl-api-key" = {
        group = cfg.name;
      };
      "${cfg.name}/discord-bot-token" = {
        group = cfg.name;
      };
      "${cfg.name}/api-server-key" = {
        group = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        FIRECRAWL_API_KEY=${config.sops.placeholder."${cfg.name}/firecrawl-api-key"}
        DISCORD_BOT_TOKEN=${config.sops.placeholder."${cfg.name}/discord-bot-token"}
        API_SERVER_KEY=${config.sops.placeholder."${cfg.name}/api-server-key"}
      '';
      group = cfg.name;
    };
  };
}
