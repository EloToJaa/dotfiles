{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop.winboat;
in {
  options.modules.desktop.winboat = {
    enable = lib.mkEnableOption "Enable winboat module";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      winboat
    ];
  };
}
