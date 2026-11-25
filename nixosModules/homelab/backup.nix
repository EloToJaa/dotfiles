{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.modules.homelab.backup.snapshots;

  snapshotPath = subvolume: "${cfg.root}${subvolume}";

  isInSubvolume = path: lib.any (subvolume: lib.hasPrefix "${subvolume}/" path) cfg.subvolumes;
  toArchivePath = path:
    if isInSubvolume path
    then "${cfg.root}/.${path}"
    else path;

  folders = lib.unique (lib.concatMap (state: state.folders) (lib.attrValues config.clan.core.state));

  postBackupCommands = lib.filter (command: command != null) (
    map (state: state.postBackupCommand) (lib.attrValues config.clan.core.state)
  );

  deleteSnapshots = ''
    for subvolume in ${lib.escapeShellArgs cfg.subvolumes}; do
      target="${cfg.root}$subvolume"
      if btrfs subvolume show "$target" &>/dev/null; then
        btrfs subvolume delete "$target"
      fi
    done
  '';

  snapshotScript = pkgs.writeShellScript "borgbackup-snapshot" ''
    set -euo pipefail
    export PATH=${lib.makeBinPath [pkgs.btrfs-progs pkgs.coreutils]}

    ${deleteSnapshots}

    for subvolume in ${lib.escapeShellArgs cfg.subvolumes}; do
      target="${cfg.root}$subvolume"
      mkdir -p "$(dirname "$target")"
      btrfs subvolume snapshot -r "$subvolume" "$target"
    done

    ${lib.concatMapStringsSep "\n" (command: ''
        echo "Restarting after snapshot: ${command}"
        /run/current-system/sw/bin/${command} || echo "${command} failed, retrying after the backup" >&2
      '')
      postBackupCommands}
  '';

  cleanupScript = pkgs.writeShellScript "borgbackup-snapshot-cleanup" ''
    set -uo pipefail
    export PATH=${lib.makeBinPath [pkgs.btrfs-progs]}

    ${deleteSnapshots}
  '';
in {
  options.modules.homelab.backup.snapshots = {
    enable = mkEnableOption ''
      backing up Clan state from read-only btrfs snapshots, so services stopped by
      pre-backup scripts restart as soon as the snapshot exists instead of after the upload
    '';
    jobs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Borgbackup job names (Clan borgbackup destinations) that read from the snapshots.";
    };
    subvolumes = mkOption {
      type = types.listOf types.str;
      default = ["/var/lib" "/opt"];
      description = "Mounted btrfs subvolumes to snapshot. State folders outside them are read in place.";
    };
    root = mkOption {
      type = types.str;
      default = "/.borg-snapshots";
      description = "Directory on the same btrfs filesystem that holds the snapshots during a backup.";
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs = lib.genAttrs cfg.jobs (_: {
      paths = lib.mkForce (map toArchivePath folders);
    });

    systemd.services = lib.genAttrs (map (job: "borgbackup-job-${job}") cfg.jobs) (_: {
      serviceConfig = {
        ExecStartPre = lib.mkAfter ["+${snapshotScript}"];
        ExecStopPost = lib.mkBefore ["-+${cleanupScript}"];
      };
    });
  };
}
