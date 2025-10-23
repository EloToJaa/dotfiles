{
  lib,
  config,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.core.adb;
in {
  options.modules.core.adb = {
    enable = lib.mkEnableOption "Enable adb module";
  };
  config = lib.mkIf cfg.enable {
    programs.adb = {
      enable = true;
    };
    users.users.${username} = {
      extraGroups = ["adbusers"];
    };
  };
}
