{
  lib,
  config,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.xandikos;
in {
  options.modules.homelab.xandikos = {
    enable = lib.mkEnableOption "Enable xandikos";
    name = lib.mkOption {
      type = lib.types.str;
      default = "xandikos";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "dav";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3006;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xandikos = {
      inherit (cfg) port;
      enable = true;
      address = "127.0.0.1";
      nginx.enable = false;
      extraOptions = [
        "--autocreate"
      ];
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    clan.core.state.xandikos = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop xandikos.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start xandikos.service
      '';
    };
  };
}
