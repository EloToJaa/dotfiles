{
  host,
  config,
  variables,
  lib,
  ...
}: let
  name = "restic";
  group = variables.homelab.groups.backups;
  backupDir = "/mnt/Backups/";
  port = 9999;
in {
  services.${name} = {
    server = {
      enable = true;
      dataDir = "${backupDir}${name}";
      # htpasswd-file = config.sops.secrets."${name}/htpasswd".path;
      listenAddress = toString port;
      extraFlags = ["--no-auth"];
    };
    backups.appdata-local = {
      timerConfig = {
        OnCalendar = "Mon..Sat *-*-* 05:00:00";
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
    };
  };
  systemd.services."${name}-rest-server".serviceConfig = {
    User = lib.mkForce name;
    Group = lib.mkForce group;
  };
  services.postgresqlBackup = {
    enable = true;
    location = "${backupDir}postgresql";
  };

  users.users.${name} = {
    description = name;
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
