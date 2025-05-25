{
  host,
  pkgs,
  config,
  ...
}: {
  services.restic = {
    server = {
      enable = true;
      dataDir = "/mnt/Backups/restic";
      extraFlags = ["--no-auth"];
    };
    backups = {
      appdata-local = {
        timerConfig = {
          OnCalendar = "Mon..Sat *-*-* 05:00:00";
          Persistent = true;
        };
        repository = "rest:http://localhost:8000/appdata-local-${host}";
        initialize = true;
        passwordFile = cfg.passwordFile;
        pruneOpts = ["--keep-last 5"];
        exclude = [];
        paths = ["/tmp/appdata-local-${host}.tar"];
        backupPrepareCommand = let
          restic = "${pkgs.restic}/bin/restic -r '${config.services.restic.backups.appdata-local.repository}' -p ${cfg.passwordFile}";
        in ''
          ${restic} stats || ${restic} init
          ${pkgs.restic}/bin/restic forget --prune --no-cache --keep-last 5
          ${pkgs.gnutar}/bin/tar -cf /tmp/appdata-local-${config.networking.hostName}.tar ${stateDirs}
          ${restic} unlock
        '';
      };
    };
  };
}
