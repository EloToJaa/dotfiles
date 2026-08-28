{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.modules.base.btrfsSnapshots;

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
  options.modules.base.btrfsSnapshots = {
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

  config = mkIf cfg.enable {
    services.snapper = {
      snapshotRootOnBoot = cfg.subvolumes ? root;
      snapshotInterval = "hourly";
      persistentTimer = true;
      cleanupInterval = "1d";
      configs = lib.mapAttrs (_: mkSnapshotConfig) cfg.subvolumes;
    };

    systemd.tmpfiles.rules =
      lib.mapAttrsToList (
        _: subvolume: "v ${snapshotDir subvolume} 0750 root root - -"
      )
      cfg.subvolumes;
  };
}
