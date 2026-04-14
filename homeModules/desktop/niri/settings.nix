{
  config,
  lib,
  settings,
  pkgs,
  ...
}: let
  inherit (settings) keyboardLayout;
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings = {
      xwayland-satellite = {
        enable = true;
        path = lib.getExe pkgs.unstable.xwayland-satellite;
      };
      input = {
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "95%";
        };
        warp-mouse-to-focus.enable = true;
        keyboard = {
          xkb = {
            layout = keyboardLayout;
            options = "grp:alt_caps_toggle";
          };
          numlock = true;
        };
        touchpad = {
          natural-scroll = true;
        };
      };

      # Layout configuration - mirrors hyprland general settings
      layout = {
        gaps = 2;
        border = {
          enable = true;
          width = 1;
        };
        focus-ring = {
          enable = true;
          width = 1;
        };
      };
      window-rules = [
        {
          geometry-corner-radius = let
            radius = 8.0;
          in {
            bottom-left = radius;
            bottom-right = radius;
            top-left = radius;
            top-right = radius;
          };
          clip-to-geometry = true;
          tiled-state = true;
          draw-border-with-background = false;
        }
      ];

      gestures.hot-corners.enable = false;

      # Environment variables - mirrors hyprland exec-once exports
      environment = {
        # Critical for electron apps
        NIXOS_OZONE_WL = "1";
        # Wayland/GTK theming
        GDK_BACKEND = "wayland";
        QT_QPA_PLATFORM = "wayland";
        MOZ_ENABLE_WAYLAND = "1";
        # Portal configuration
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
        GTK_USE_PORTAL = "1";
        DISPLAY = ":0";

        DMS_SCREENSHOT_EDITOR = "satty";
      };

      # Misc settings - mirrors hyprland misc section
      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;
    };
  };
}
