{
  lib,
  config,
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
      enable = true;
      addToSystemPackages = true;
      stateDir = cfg.dataDir;
      environmentFiles = [config.sops.templates."${cfg.name}.env".path];

      container = {
        enable = true;
        backend = "podman";
        hostUsers = [username];
        image = "ubuntu:24.04";
      };

      settings = {
        model = {
          provider = "opencode-go";
          default = "kimi-k2.6";
        };
        web.backend = "firecrawl";
      };
      environment = {
        DISCORD_ALLOWED_USERS = "308939544407834625";
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

    clan.core.state.open-webui = {
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
        OPENCODE_GO_API_KEY=${config.sops.placeholder."${cfg.name}/opencode-api-key"}
        OPENCODE_ZEN_API_KEY=${config.sops.placeholder."${cfg.name}/opencode-api-key"}
        FIRECRAWL_API_KEY=${config.sops.placeholder."${cfg.name}/firecrawl-api-key"}
        DISCORD_BOT_TOKEN=${config.sops.placeholder."${cfg.name}/discord-bot-token"}
        API_SERVER_KEY=${config.sops.placeholder."${cfg.name}/api-server-key"}
      '';
      group = cfg.name;
    };
  };
}
