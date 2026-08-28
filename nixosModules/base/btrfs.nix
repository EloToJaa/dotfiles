{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types;
  cfg = config.modules.base.btrfs;

  snapshotDir = subvolume: "${lib.removeSuffix "/" (toString subvolume)}/.snapshots";
  mkSnapshotConfig = subvolume: {
    SUBVOLUME = subvolume;
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 24;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 3;
    TIMELINE_LIMIT_YEARLY = 0;
  };
in {
  options.modules.base.btrfs = {
    snapshots = {
      enable = mkEnableOption "Btrfs snapshots";
      subvolumes = mkOption {
        type = types.attrsOf types.path;
        default = {
          root = "/";
          home = "/home";
        };
        description = "Btrfs subvolumes managed by Snapper, keyed by Snapper configuration name.";
      };
    };

    scrub = {
      enable = mkEnableOption "periodic Btrfs scrubbing";
      interval = mkOption {
        type = types.str;
        default = "monthly";
        description = "Systemd calendar interval for Btrfs scrubbing.";
      };
      fileSystems = mkOption {
        type = types.listOf types.str;
        default = ["/"];
        description = "Btrfs filesystems to scrub.";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.snapshots.enable {
      services.snapper = {
        snapshotRootOnBoot = cfg.snapshots.subvolumes ? root;
        snapshotInterval = "hourly";
        persistentTimer = true;
        cleanupInterval = "1d";
        configs = lib.mapAttrs (_: mkSnapshotConfig) cfg.snapshots.subvolumes;
      };

      systemd.tmpfiles.rules =
        lib.mapAttrsToList (
          _: subvolume: "v ${snapshotDir subvolume} 0750 root root - -"
        )
        cfg.snapshots.subvolumes;
    })

    (mkIf cfg.scrub.enable {
      services.btrfs.autoScrub = {
        inherit (cfg.scrub) fileSystems interval;
        enable = true;
      };
    })
  ];
}
