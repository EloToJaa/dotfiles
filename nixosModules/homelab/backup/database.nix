{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.homelab.backup;

  mkBackupServiceConfig = {
    dbName,
    fileEncKey,
    backupDir,
  }: (import ./pg-db-archive.nix {
    inherit config pkgs dbName fileEncKey backupDir;
  });
in {
  config = lib.mkIf cfg.enable {
    services.postgresqlBackup = {
      enable = true;
      location = cfg.postgresBackupDir;
      startAt = "*-*-* 02:00:00";
      pgdumpOptions = "--no-owner";
    };

    # systemd.services."postgresqlBackup-db1".serviceConfig = (import ./pg-db-archive.nix) {
    #   inherit config pkgs;
    #   dbName = "db1";
    #   fileEncKey = "/run/secrets/keys/db1";
    #   fileRclone = "/run/secrets/rclone/database-archive.conf";
    # };

    systemd.services = builtins.listToAttrs (map (dbName: {
        name = "postgresqlBackup-${dbName}";
        value.serviceConfig = mkBackupServiceConfig {
          inherit dbName;
          fileEncKey = config.sops.secrets."backup/database".path;
          backupDir = "/mnt/Backups/database";
        };
      })
      config.services.postgresqlBackup.databases);

    sops.secrets = {
      "backup/database" = {
        owner = "postgres";
      };
    };
  };
}
