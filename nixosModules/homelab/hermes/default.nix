{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.settings) username;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.hermes;
  proxyBaseUrl = "http://127.0.0.1:${toString homelab.cliproxyapi.port}/v1";
  homeAssistant = config.modules.homelab.home-assistant;
  secretEnv =
    {
      FIRECRAWL_API_KEY = "firecrawl-api-key";
      DISCORD_BOT_TOKEN = "discord-bot-token";
      API_SERVER_KEY = "api-server-key";
    }
    // lib.optionalAttrs homeAssistant.enable {
      HASS_TOKEN = "hass-token";
    };
  externalSecrets =
    {
      opencode-api-key = "OpenCode API key";
      firecrawl-api-key = "Firecrawl API key";
      discord-bot-token = "Discord bot token";
    }
    // lib.optionalAttrs homeAssistant.enable {
      hass-token = "Home Assistant long-lived access token";
    };
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
    assertions = [
      {
        assertion = homelab.cliproxyapi.enable;
        message = "modules.homelab.hermes requires modules.homelab.cliproxyapi.enable = true;";
      }
    ];

    clan.core.vars.generators.hermes-cliproxyapi = {
      dependencies = ["cliproxyapi"];
      files.env = {
        owner = config.services.hermes-agent.user;
        group = config.services.hermes-agent.group;
      };
      script = ''
        printf 'OPENAI_API_KEY=%s\n' "$(cat "$in/cliproxyapi/api-key")" > "$out/env"
      '';
    };

    systemd.services.hermes-agent = {
      after = ["cliproxyapi.service"];
      requires = ["cliproxyapi.service"];
    };

    services.hermes-agent = {
      # package = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.messaging;
      enable = true;
      addToSystemPackages = true;
      stateDir = cfg.dataDir;
      environmentFiles = [
        config.clan.core.vars.generators."${cfg.name}-env".files.env.path
        config.clan.core.vars.generators.hermes-cliproxyapi.files.env.path
      ];

      extraDependencyGroups = [
        "messaging"
        "homeassistant"
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

      settings =
        {
          # terminal.cwd = "/data/workspace";
          model = {
            provider = "custom";
            base_url = proxyBaseUrl;
            default = "gpt-6-luna";
          };
          web = {
            search_backend = "ddgs";
            extract_backend = "firecrawl";
          };
        }
        // lib.optionalAttrs homeAssistant.enable {
          platforms.homeassistant = {
            enabled = true;
            extra = {
              watch_domains = [
                "climate"
                "binary_sensor"
                "alarm_control_panel"
                "light"
              ];
              cooldown_seconds = 30;
            };
          };
        };
      environment =
        {
          OPENAI_BASE_URL = proxyBaseUrl;
          DISCORD_ALLOWED_USERS = "308939544407834625";
          # Hermes v0.16 emits a /skill slash-command payload over Discord's
          # 8000-byte limit. Plain text commands still work; don't sync invalid
          # native slash commands at startup.
          # DISCORD_COMMAND_SYNC_POLICY = "off";
          API_SERVER_ENABLED = "true";
          API_SERVER_PORT = toString cfg.port;
          API_SERVER_HOST = "127.0.0.1";
        }
        // lib.optionalAttrs homeAssistant.enable {
          HASS_URL = "http://127.0.0.1:${toString homeAssistant.port}";
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

    clan.core.vars.generators.${cfg.name} = {
      prompts =
        lib.mapAttrs (_: description: {
          inherit description;
          type = "hidden";
          persist = true;
        })
        externalSecrets;
      files =
        {opencode-api-key.group = cfg.name;}
        // lib.genAttrs (lib.attrValues secretEnv) (_: {deploy = false;});
      runtimeInputs = [pkgs.pwgen];
      script = ''
        pwgen -s 64 1 | tr -d '\n' > "$out/api-server-key"
      '';
    };
    clan.core.vars.generators."${cfg.name}-env" = {
      dependencies = [cfg.name];
      files.env.group = cfg.name;
      script = lib.concatStrings (
        lib.mapAttrsToList (name: file: ''
          printf '%s=%s\n' ${name} "$(cat "$in/${cfg.name}/${file}")" >> "$out/env"
        '')
        secretEnv
      );
    };
  };
}
