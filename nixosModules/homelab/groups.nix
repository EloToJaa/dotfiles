{
  config,
  lib,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.homelab.groups;
in {
  options.modules.homelab.groups = {
    enable = lib.mkEnableOption "Enable homelab groups";
  };
  config = lib.mkIf cfg.enable {
    users.users.${username}.extraGroups = with cfg; [
      main
      cloud
      media
      photos
      docs
      database
      backups
    ];

    users.groups = with cfg; {
      ${main}.gid = 1100;
      ${media}.gid = 1101;
      ${photos}.gid = 1102;
      ${docs}.gid = 1103;
      ${database}.gid = 1104;
      ${backups}.gid = 1105;
      ${cloud}.gid = 1106;
    };
  };
}
