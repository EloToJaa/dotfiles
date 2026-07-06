{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.navidrome;
in {
  options.modules.homelab.navidrome = {
    enable = lib.mkEnableOption "Enable navidrome";
    name = lib.mkOption {
      type = lib.types.str;
      default = "navidrome";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "music";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.media;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 4533;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    cacheDir = lib.mkOption {
      type = lib.types.path;
      default = "${cfg.dataDir}/cache";
    };
    musicFolder = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/Media/Music";
    };
  };

  config = lib.mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      user = cfg.name;
      inherit (cfg) group;
      package = pkgs.unstable.navidrome;
      settings = {
        Address = "127.0.0.1";
        Port = cfg.port;
        DataFolder = cfg.dataDir;
        CacheFolder = cfg.cacheDir;
        MusicFolder = cfg.musicFolder;
      };
    };

    systemd.services.navidrome.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      "d ${cfg.cacheDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    clan.core.state.navidrome = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop navidrome.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start navidrome.service
      '';
    };

    services.nginx.virtualHosts = let
      proxyConfig = {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    in {
      "${cfg.domainName}.${homelab.baseDomain}" = proxyConfig // {useACMEHost = homelab.baseDomain;};
      "${cfg.domainName}.${homelab.mainDomain}" = proxyConfig // {useACMEHost = homelab.mainDomain;};
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      inherit (cfg) group;
    };
  };
}
