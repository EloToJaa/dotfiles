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
  hermesPackage = let
    hermesVenv = pkgs.callPackage "${inputs.hermes-agent}/nix/python.nix" {
      inherit (inputs.hermes-agent.inputs) uv2nix pyproject-nix pyproject-build-systems;
    };
    bundledSkills = pkgs.lib.cleanSourceWith {
      src = "${inputs.hermes-agent}/skills";
      filter = path: _type: !(pkgs.lib.hasInfix "/index-cache/" path);
    };
    runtimeDeps = with pkgs; [
      nodejs_20
      ripgrep
      git
      openssh
      ffmpeg
      tirith
    ];
    runtimePath = pkgs.lib.makeBinPath runtimeDeps;
  in
    pkgs.stdenv.mkDerivation {
      pname = "hermes-agent";
      version = (builtins.fromTOML (builtins.readFile "${inputs.hermes-agent}/pyproject.toml")).project.version;

      dontUnpack = true;
      dontBuild = true;
      nativeBuildInputs = [pkgs.makeWrapper];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/hermes-agent $out/bin
        cp -r ${bundledSkills} $out/share/hermes-agent/skills

        ${pkgs.lib.concatMapStringsSep "\n" (name: ''
          makeWrapper ${hermesVenv}/bin/${name} $out/bin/${name} \
            --suffix PATH : "${runtimePath}" \
            --set HERMES_BUNDLED_SKILLS $out/share/hermes-agent/skills
        '') ["hermes" "hermes-agent" "hermes-acp"]}

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "AI agent with advanced tool-calling capabilities";
        homepage = "https://github.com/NousResearch/hermes-agent";
        mainProgram = "hermes";
        license = licenses.mit;
        platforms = platforms.unix;
      };
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
    services.hermes-agent = {
      enable = true;
      package = hermesPackage;
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
          provider = "openai-codex";
          default = "gpt-5.5";
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
        FIRECRAWL_API_KEY=${config.sops.placeholder."${cfg.name}/firecrawl-api-key"}
        DISCORD_BOT_TOKEN=${config.sops.placeholder."${cfg.name}/discord-bot-token"}
        API_SERVER_KEY=${config.sops.placeholder."${cfg.name}/api-server-key"}
      '';
      group = cfg.name;
    };
  };
}
