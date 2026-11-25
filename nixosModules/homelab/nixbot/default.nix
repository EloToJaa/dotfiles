{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.nixbot;
  credentials = config.clan.core.vars.generators.nixbot-github.files;
  ready = credentials.app-id.exists && credentials.oauth-id.exists;
  domain = "${cfg.domainName}.${homelab.mainDomain}";
in {
  imports = [inputs.nixbot.nixosModules.nixbot];

  options.modules.homelab.nixbot = {
    enable = lib.mkEnableOption "Nixbot CI and scheduled update PRs";
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "nixbot";
    };
    metricsPort = lib.mkOption {
      type = lib.types.port;
      default = 9010;
      description = "Loopback port that proxies Nixbot's /metrics, which the service only serves on a unix socket";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      modules.homelab.glance.sites = [
        {
          title = "Nixbot";
          group = "ci";
          url = "https://${cfg.domainName}.${homelab.mainDomain}";
          checkUrl = "https://${cfg.domainName}.${homelab.mainDomain}/health";
          icon = "di:nixos";
        }
      ];

      modules.homelab.gatus.endpoints = [
        {
          name = "Nixbot";
          group = "ci";
          url = "https://${cfg.domainName}.${homelab.mainDomain}/health";
          conditions = ["[STATUS] == 200"];
        }
      ];
      warnings = lib.optional (!ready) "Nixbot awaits GitHub App provisioning: run clan vars generate ${config.networking.hostName} --generator nixbot-github; see ci/README.md. The service remains disabled until its public App/OAuth IDs exist.";
      clan.core.vars.generators.nixbot-github = {
        prompts = {
          app-id = {
            description = "GitHub App numeric ID";
            type = "line";
          };
          oauth-id = {
            description = "GitHub App OAuth client ID";
            type = "line";
          };
          private-key-base64 = {
            description = "GitHub App PEM private key encoded with base64 -w0";
            type = "hidden";
          };
          oauth-secret = {
            description = "GitHub App OAuth client secret";
            type = "hidden";
          };
        };
        files = {
          app-id = {
            secret = false;
            deploy = false;
          };
          oauth-id = {
            secret = false;
            deploy = false;
          };
          private-key = {};
          oauth-secret = {};
          webhook-secret = {};
        };
        runtimeInputs = [pkgs.coreutils pkgs.gnugrep pkgs.openssl];
        script = ''
          set -euo pipefail
          grep -Eq '^[1-9][0-9]*$' "$prompts/app-id"
          tr -d '\n' < "$prompts/app-id" > "$out/app-id"
          tr -d '\n' < "$prompts/oauth-id" > "$out/oauth-id"
          base64 --decode < "$prompts/private-key-base64" > "$out/private-key"
          openssl pkey -in "$out/private-key" -noout
          tr -d '\n' < "$prompts/oauth-secret" > "$out/oauth-secret"
          openssl rand -hex 32 > "$out/webhook-secret"
        '';
      };
    }
    (lib.mkIf ready {
      services.nixbot = {
        enable = true;
        inherit domain;
        admins = ["github:EloToJaa"];
        # Parallel host checks wait silently on shared derivations (e.g. LTO
        # links, Rust builds without a binary cache), which the 20 minute
        # default kills. Flake updates can rebuild several of these at once.
        buildMaxSilentTime = 3 * 60 * 60;
        github = {
          enable = true;
          appId = builtins.fromJSON credentials.app-id.value;
          oauthId = lib.trim credentials.oauth-id.value;
          appSecretKeyFile = credentials.private-key.path;
          oauthSecretFile = credentials.oauth-secret.path;
          webhookSecretFile = credentials.webhook-secret.path;
          repoAllowlist = ["EloToJaa/dotfiles"];
          topic = null;
        };
      };
      services.nginx.virtualHosts = {
        ${domain} = {
          forceSSL = true;
          useACMEHost = homelab.mainDomain;
        };
        nixbot-metrics = {
          listen = [
            {
              addr = "127.0.0.1";
              port = cfg.metricsPort;
            }
          ];
          locations."= /metrics".proxyPass = "http://unix:/run/nixbot/web.sock";
        };
      };
      modules.homelab.prometheus.scrapeTargets = [
        {
          job_name = "nixbot";
          address = "127.0.0.1:${toString cfg.metricsPort}";
        }
      ];
      clan.core.postgresql.databases.nixbot = {
        create.enable = false;
        restore.stopOnRestore = ["nixbot"];
      };
      clan.core.state.nixbot.folders = ["/var/lib/nixbot"];
    })
  ]);
}
