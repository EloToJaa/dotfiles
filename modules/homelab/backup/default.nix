{
  host,
  config,
  variables,
  lib,
  pkgs,
  ...
}: let
  name = "restic";
  group = variables.homelab.groups.backups;
  backupDir = "/mnt/Backups/${name}/";
  postgresBackupDir = "/var/backup/postgresql/";
  port = 9999;
in {
  services.${name} = {
    server = {
      enable = true;
      package = pkgs.unstable.restic-rest-server;
      dataDir = backupDir;
      # htpasswd-file = config.sops.secrets."${name}/htpasswd".path;
      listenAddress = toString port;
      extraFlags = ["--no-auth"];
    };
    backups.appdata-local = {
      package = pkgs.unstable.restic;
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
      repository = "rest:http://localhost:${toString port}/appdata-local-${host}";
      initialize = true;
      passwordFile = config.sops.secrets."${name}/password".path;
      pruneOpts = [
        "--keep-daily 5"
        "--keep-weekly 2"
        "--keep-monthly 1"
      ];
      exclude = [];
      paths = [postgresBackupDir];
    };
  };
  systemd.services."${name}-rest-server".serviceConfig = {
    Group = lib.mkForce group;
  };
  services.postgresqlBackup = {
    enable = true;
    location = postgresBackupDir;
    startAt = "*-*-* 02:00:00";
  };

  users.users.${name} = {
    group = lib.mkForce group;
  };

  sops.secrets = {
    "${name}/password" = {
      owner = name;
    };
    "${name}/htpasswd" = {
      owner = name;
    };
  };
}
