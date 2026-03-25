{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) keyboardLayout;
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings = {
      # Input configuration - mirrors hyprland settings.nix
      input = {
        keyboard.xkb = {
          layout = keyboardLayout;
          options = "grp:alt_caps_toggle";
        };
        touchpad = {
          natural-scroll = true;
        };
      };

      # Layout configuration - mirrors hyprland general settings
      layout = {
        gaps = 0;
        border = {
          enable = true;
          width = 2;
        };
      };

      # Environment variables - mirrors hyprland exec-once exports
      environment = {
        # Critical for electron apps
        NIXOS_OZONE_WL = "1";
        # Wayland/GTK theming
        GDK_BACKEND = "wayland";
        QT_QPA_PLATFORM = "wayland";
        MOZ_ENABLE_WAYLAND = "1";

        DMS_SCREENSHOT_EDITOR = "satty";
      };

      # Misc settings - mirrors hyprland misc section
      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;
    };
  };
}
