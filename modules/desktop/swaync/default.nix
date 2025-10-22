{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop.swaync;
in {
  options.modules.desktop.swaync = {
    enable = lib.mkEnableOption "Enable swaync";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [swaynotificationcenter];
    xdg.configFile."swaync/style.css".source = ./style.css;
    xdg.configFile."swaync/config.json".source = ./config.json;
  };
}
