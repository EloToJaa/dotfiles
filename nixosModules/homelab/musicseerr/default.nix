{
  config,
  lib,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.musicseerr;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "musicseerr";
    port = 8688;
    description = "Enable MusicSeerr";
    domainName = "ms";
    gatus = {
      name = "MusicSeerr";
      group = "media";
      path = "/health";
    };
  };
in {
  imports = [
    ./service.nix
  ];

  options.modules.homelab.musicseerr =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.media;
      };
    };

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.musicseerr = {
        inherit (cfg) port dataDir group;
        package = pkgs.musicseerr;
        enable = true;
        user = cfg.name;
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
    })
  ];
}
