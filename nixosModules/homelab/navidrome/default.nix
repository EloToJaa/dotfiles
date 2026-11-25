{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.navidrome;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "navidrome";
    port = 4533;
    domainName = "music";
    mainDomain = true;
    glance.icon = "di:navidrome";
    gatus = {
      name = "Navidrome";
      group = "media";
      path = "/ping";
    };
    umaskUnits = ["navidrome"];
  };
in {
  options.modules.homelab.navidrome =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.media;
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

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
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

      users.users.${cfg.name} = {
        isSystemUser = true;
        description = cfg.name;
        inherit (cfg) group;
      };
    })
  ];
}
