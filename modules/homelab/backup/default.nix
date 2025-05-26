{
  host,
  config,
  ...
}: let
  name = "restic";
  backupDir = "/mnt/Backups/";
in {
  services.${name} = {
    server = {
      enable = true;
      dataDir = "${backupDir}${name}";
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

  sops.secrets = {
    "${name}/password" = {
      owner = name;
    };
  };
}
