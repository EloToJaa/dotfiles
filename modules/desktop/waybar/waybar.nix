{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.waybar;
in {
  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = pkgs.unstable.waybar.overrideAttrs (oa: {
        mesonFlags = (oa.mesonFlags or []) ++ ["-Dexperimental=true"];
      });
    };
  };
}
