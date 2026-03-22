{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) terminal discord;
  inherit (config.modules.desktop) mainMod;
  cfg = config.modules.desktop.niri;

  # Map mainMod to niri modifier syntax
  mod = "Mod"; # SUPER key
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings.binds = {
      # Applications
      "${mod}+Return" = {action.spawn = [terminal];};
      "${mod}+b" = {action.spawn = ["uwsm" "app" "--" "zen-beta"];};
      "${mod}+q" = {action.close-window = {};};
      "${mod}+f" = {action.fullscreen-window = {};};
      "${mod}+Space" = {action.toggle-window-floating = {};};
      "${mod}+s" = {action.spawn = ["uwsm" "app" "--" "vicinae" "toggle"];};
      "${mod}+d" = {action.spawn = [discord];};
      "${mod}+e" = {action.spawn = ["uwsm" "app" "--" "nemo"];};
      "${mod}+n" = {action.spawn = ["uwsm" "app" "--" "swaync-client" "-t" "-sw"];};

      # Screenshots
      "Print" = {action.spawn = ["uwsm" "app" "--" "screenshot" "--copy"];};
      "${mod}+Print" = {action.spawn = ["uwsm" "app" "--" "screenshot" "--save"];};

      # Focus movement
      "${mod}+Left" = {action.focus-column-left = {};};
      "${mod}+Right" = {action.focus-column-right = {};};
      "${mod}+h" = {action.focus-column-left = {};};
      "${mod}+l" = {action.focus-column-right = {};};
      "${mod}+Up" = {action.focus-window-up = {};};
      "${mod}+Down" = {action.focus-window-down = {};};

      # Workspaces 1-10
      "${mod}+1" = {action.focus-workspace = [1];};
      "${mod}+2" = {action.focus-workspace = [2];};
      "${mod}+3" = {action.focus-workspace = [3];};
      "${mod}+4" = {action.focus-workspace = [4];};
      "${mod}+5" = {action.focus-workspace = [5];};
      "${mod}+6" = {action.focus-workspace = [6];};
      "${mod}+7" = {action.focus-workspace = [7];};
      "${mod}+8" = {action.focus-workspace = [8];};
      "${mod}+9" = {action.focus-workspace = [9];};
      "${mod}+0" = {action.focus-workspace = [10];};

      # Move window to workspace
      "${mod}+Shift+1" = {action.move-column-to-workspace = [1];};
      "${mod}+Shift+2" = {action.move-column-to-workspace = [2];};
      "${mod}+Shift+3" = {action.move-column-to-workspace = [3];};
      "${mod}+Shift+4" = {action.move-column-to-workspace = [4];};
      "${mod}+Shift+5" = {action.move-column-to-workspace = [5];};
      "${mod}+Shift+6" = {action.move-column-to-workspace = [6];};
      "${mod}+Shift+7" = {action.move-column-to-workspace = [7];};
      "${mod}+Shift+8" = {action.move-column-to-workspace = [8];};
      "${mod}+Shift+9" = {action.move-column-to-workspace = [9];};
      "${mod}+Shift+0" = {action.move-column-to-workspace = [10];};

      # Change monitor focus
      "${mod}+Tab" = {action.focus-monitor-next = {};};
      "${mod}+Shift+Tab" = {action.focus-monitor-previous = {};};

      # Window movement
      "${mod}+Shift+Left" = {action.move-column-left = {};};
      "${mod}+Shift+Right" = {action.move-column-right = {};};

      # Media controls
      "XF86AudioPlay" = {action.spawn = ["playerctl" "play-pause"];};
      "XF86AudioNext" = {action.spawn = ["playerctl" "next"];};
      "XF86AudioPrev" = {action.spawn = ["playerctl" "previous"];};

      # Lock screen - hyprlock works on any Wayland compositor
      "${mod}+g" = {action.spawn = ["hyprlock"];};

      # Logout menu
      "${mod}+Escape" = {action.spawn = ["uwsm" "app" "--" "wlogout"];};
    };
  };
}
