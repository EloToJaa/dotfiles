{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.core.wayland;
in {
  imports = [inputs.umbriel.nixosModules.default];

  config = lib.mkIf (config.modules.core.enable && cfg.enable && cfg.umbriel.enable) {
    programs.umbriel.enable = true;

    # umbriel's portal config falls back to gtk but does not install it; gtk provides
    # the Settings interface libadwaita apps (Nautilus) read dark mode from.
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
