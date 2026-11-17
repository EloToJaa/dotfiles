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
    programs.umbriel = {
      enable = true;
      # Upstream's dbus-run-session tests look for /etc/dbus-1/session.conf, which
      # does not exist in the build sandbox; point them at the store copy instead.
      portalPackage = inputs.xdg-desktop-portal-umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            substituteInPlace meson.build \
              --replace-fail "find_program('dbus-run-session'), args: ['--'," \
                "find_program('dbus-run-session'), args: ['--config-file=${pkgs.dbus}/share/dbus-1/session.conf', '--',"
          '';
      });
    };

    # umbriel's portal config falls back to gtk but does not install it; gtk provides
    # the Settings interface libadwaita apps (Nautilus) read dark mode from.
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
