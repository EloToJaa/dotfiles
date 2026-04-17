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
      default = 3005;
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

      settings.model.default = "opencode-go/kimi-k2.5";
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
      "${cfg.name}/oc-api-key" = {
        group = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        OPENCODE_GO_API_KEY=${config.sops.placeholder."${cfg.name}/oc-api-key"}
      '';
      group = cfg.name;
    };
  };
}
