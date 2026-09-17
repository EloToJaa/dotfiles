{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) keyboardLayout;
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.config = {
      input = {
        kb_layout = keyboardLayout;
        # Preserve the established Alt+Caps layout switch; Menu is Compose.
        kb_options = "grp:alt_caps_toggle,compose:menu";
        numlock_by_default = true;
        follow_mouse = 0;
        float_switch_override_focus = 0;
        mouse_refocus = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        layout = "dwindle";
        gaps_in = 0;
        gaps_out = 0;
        border_size = 2;
        col = {
          active_border = {
            colors = ["rgb(98971a)" "rgb(cc241d)"];
            angle = 45;
          };
          inactive_border = "rgba(00000000)";
        };
      };

      misc = {
        disable_autoreload = false;
        disable_hyprland_logo = true;
        always_follow_on_dnd = true;
        layers_hog_keyboard_focus = true;
        animate_manual_resizes = false;
        enable_swallow = true;
        focus_on_activate = true;
        on_focus_under_fullscreen = 2;
        middle_click_paste = false;
      };

      dwindle = {
        # no_gaps_when_only = 0;
        force_split = 0;
        special_scale_factor = 1;
        split_width_multiplier = 1;
        use_active_for_splits = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
        special_scale_factor = 1;
        # no_gaps_when_only = 0;
      };

      scrolling = {
        fullscreen_on_one_column = true;
      };

      decoration = {
        rounding = 0;
        # active_opacity = 0.90;
        # inactive_opacity = 0.90;
        # fullscreen_opacity = 1.0;
        border_part_of_window = true;

        blur = {
          enabled = true;
          size = 3;
          passes = 2;
          brightness = 1;
          contrast = 1.4;
          ignore_opacity = true;
          noise = 0;
          new_optimizations = true;
          xray = true;
        };

        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          offset = "0 2";
          color = "rgba(00000055)";
        };
      };

      ecosystem = {
        no_update_news = false;
        no_donation_nag = true;
      };

      xwayland = {
        force_zero_scaling = true;
      };
    };
    wayland.windowManager.hyprland.extraLuaFiles.animations = ./animations.lua;
  };
}
