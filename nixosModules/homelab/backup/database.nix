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
    keepLast,
  }: (import ./pg-db-archive.nix {
    inherit config pkgs dbName fileEncKey backupDir keepLast;
  });
in {
  config = lib.mkIf cfg.enable {
    services.postgresqlBackup = {
      enable = true;
      location = cfg.postgresBackupDir;
      startAt = "*-*-* 02:00:00";
      pgdumpOptions = "--no-owner";
    };

    systemd.services = builtins.listToAttrs (map (dbName: {
        name = "postgresqlBackup-${dbName}";
        value.serviceConfig = mkBackupServiceConfig {
          inherit dbName;
          keepLast = 14;
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
