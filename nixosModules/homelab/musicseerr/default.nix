{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.musicseerr;
in {
  imports = [
    ./service.nix
  ];

  options.modules.homelab.musicseerr = {
    enable = lib.mkEnableOption "Enable MusicSeerr";
    name = lib.mkOption {
      type = lib.types.str;
      default = "musicseerr";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "ms";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.media;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8688;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.musicseerr = {
      inherit (cfg) port dataDir group;
      package = pkgs.musicseerr;
      enable = true;
      user = cfg.name;
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    clan.core.state.musicseerr = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop musicseerr.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start musicseerr.service
      '';
    };
  };
}
