{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.open-webui;
in {
  options.modules.homelab.open-webui = {
    enable = lib.mkEnableOption "Enable open-webui";
    name = lib.mkOption {
      type = lib.types.str;
      default = "open-webui";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "chat";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3004;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.open-webui = {
      inherit (cfg) port;
      enable = true;
      package = pkgs.unstable.open-webui;
      host = "127.0.0.1";
      stateDir = cfg.dataDir;
      # environmentFile = config.sops.templates."${cfg.name}.env".path;
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

        systemctl stop open-webui.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start open-webui.service
      '';
    };

    # sops.secrets = {
    #   "${cfg.name}/pgpassword" = {
    #     owner = cfg.name;
    #   };
    # };
    # sops.templates."${cfg.name}.env" = {
    #   content = ''
    #     POSTGRES_PASSWORD=${config.sops.placeholder."${cfg.name}/pgpassword"}
    #   '';
    #   owner = cfg.name;
    # };
  };
}
