{
  config,
  lib,
  settings,
  pkgs,
  inputs,
  ...
}: let
  inherit (settings) keyboardLayout;
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.oniri
      inputs.niri-session-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    wayland.windowManager.niri = {
      enable = true;
      package = pkgs.unstable.niri;
      xwaylandSatellitePackage = pkgs.unstable.xwayland-satellite;
      checkConfig = false;

      settings = {
        input = {
          focus-follows-mouse._props.max-scroll-amount = "95%";
          warp-mouse-to-focus = [];
          keyboard = {
            xkb = {
              layout = keyboardLayout;
              # Caps Lock is already the established Alt+Caps layout switch.
              # Menu is the Compose key so the existing convention keeps working.
              options = "grp:alt_caps_toggle,compose:menu";
            };
            numlock = true;
          };
          touchpad = {
            natural-scroll = [];
          };
        };
        cursor = {
          xcursor-theme = "Bibata-Modern-Ice";
          xcursor-size = 24;
        };

        # Layout configuration - mirrors hyprland general settings
        layout = {
          gaps = 2;
          border = {
            on = [];
            width = 1;
          };
          focus-ring = {
            on = [];
            width = 1;
          };
        };
        layer-rule._children = [
          {
            match._props.namespace = "dms:blurwallpaper";
            place-within-backdrop = true;
          }
        ];

        gestures.hot-corners.off = [];

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

          DMS_SCREENSHOT_EDITOR = "satty";
        };

        # Misc settings - mirrors hyprland misc section
        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;
      };
    };
    # wayland.windowManager.niri.systemd.variables = [
    #   "--all"
    # ];
  };
}
