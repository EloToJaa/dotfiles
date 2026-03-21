{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    programs.niri = lib.mkIf cfg.niri.enable {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
