{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.core.wayland;
in {
  config = lib.mkIf (config.modules.core.enable && cfg.enable && cfg.luciole.enable) {
    # xdg-desktop-portal-umbriel already prefers the luciole FileChooser once it is registered.
    xdg.portal.extraPortals = [inputs.luciole.packages.${pkgs.stdenv.hostPlatform.system}.default];
    services.gvfs.enable = true;
  };
}
