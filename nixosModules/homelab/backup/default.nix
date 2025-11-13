{
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.backup;
in {
  options.modules.homelab.backup = {
    enable = lib.mkEnableOption "Enable backup";
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
  imports = [
    ./database.nix
    ./files.nix
  ];
}
