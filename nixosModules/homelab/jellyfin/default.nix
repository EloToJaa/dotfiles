{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.jellyfin;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "jellyfin";
    port = 8096;
    domainName = "watch";
    mainDomain = true;
    gatus = {
      name = "Jellyfin";
      group = "media";
      path = "/health";
    };
    umaskUnits = ["jellyfin"];
  };
in {
  options.modules.homelab.jellyfin =
    service.options
    // {
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.media;
      };
      logDir = lib.mkOption {
        type = lib.types.path;
        default = "${homelab.logDir}${cfg.name}";
      };
    };
  imports = [
    ./auth.nix
  ];
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.jellyfin = {
        enable = true;
        package = pkgs.unstable.jellyfin;
        user = cfg.name;
        inherit (cfg) group dataDir logDir openFirewall;
      };
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
        "d ${cfg.logDir} 750 ${cfg.name} ${cfg.group} - -"
      ];
      clan.core.state.jellyfin = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop jellyfin.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start jellyfin.service
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
