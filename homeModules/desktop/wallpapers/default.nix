{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.wallpapers;
in {
  options.modules.desktop.wallpapers = {
    enable = lib.mkEnableOption "Enable wallpapers";
  };
  config = lib.mkIf cfg.enable {
    home.file."Pictures/wallpapers" = {
      source = ./wallpapers;
      recursive = true;
    };
  };
}
