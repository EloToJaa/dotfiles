{
  host,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules.homelab) homelab;
  cfg = config.modules.homelab.backup;
in {
  options.modules.homelab.backup = {
    enable = lib.mkEnableOption "Backup module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "restic";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.backups;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9999;
    };
    backupDir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/Backups/${cfg.name}/";
    };
    postgresBackupDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/backup/postgresql/";
    };
  };
  config = lib.mkIf cfg.enable {
    services.restic = {
      server = {
        enable = true;
        package = pkgs.unstable.restic-rest-server;
        dataDir = cfg.backupDir;
        # htpasswd-file = config.sops.secrets."${name}/htpasswd".path;
        listenAddress = toString cfg.port;
        extraFlags = ["--no-auth"];
      };
      backups.appdata-local = {
        package = pkgs.unstable.restic;
        timerConfig = {
          OnCalendar = "*-*-* 03:00:00";
          Persistent = true;
        };
        repository = "rest:http://127.0.0.1:${toString cfg.port}/appdata-local-${host}";
        initialize = true;
        passwordFile = config.sops.secrets."${cfg.name}/password".path;
        pruneOpts = [
          "--keep-daily 5"
          "--keep-weekly 2"
          "--keep-monthly 1"
        ];
        exclude = [];
        paths = [cfg.postgresBackupDir];
      };
    };
    systemd.services."${cfg.name}-rest-server".serviceConfig = {
      Group = lib.mkForce cfg.group;
    };
    services.postgresqlBackup = {
      enable = true;
      location = cfg.postgresBackupDir;
      startAt = "*-*-* 02:00:00";
    };

    users.users.${cfg.name} = {
      group = lib.mkForce cfg.group;
    };

    sops.secrets = {
      "${cfg.name}/password" = {
        owner = cfg.name;
      };
      "${cfg.name}/htpasswd" = {
        owner = cfg.name;
      };
    };
  };
}
