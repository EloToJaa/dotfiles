{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    # Disable home-manager xdg.portal management - handled at NixOS level
    # This prevents conflicts between hyprland (sets false) and niri (sets true) modules
    xdg.portal.enable = lib.mkForce false;

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
