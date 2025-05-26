{
  host,
  config,
  variables,
  ...
}: let
  name = "restic";
  group = variables.homelab.groups.main;
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
      repository = "rest:http://localhost:8000/appdata-local-${host}";
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
  services.postgresqlBackup = {
    enable = true;
    location = "${backupDir}postgresql";
  };

  users.users.${name} = {
    isSystemUser = true;
    description = name;
    group = group;
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
