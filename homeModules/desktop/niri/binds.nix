{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) terminal discord;
  cfg = config.modules.desktop.niri;

  # Helper to wrap commands with uwsm
  uwsmApp = command: ["uwsm" "app" "--"] ++ command;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings.binds = {
      # Applications
      "Mod+Return" = {action.spawn = uwsmApp [terminal];};
      "Mod+b" = {action.spawn = uwsmApp ["zen-beta"];};
      "Mod+q" = {action.close-window = {};};
      "Mod+f" = {action.fullscreen-window = {};};
      # "Mod+Space" = {action.toggle-window-floating = {};};
      "Mod+s" = {action.spawn = uwsmApp ["vicinae" "toggle"];};
      "Mod+d" = {action.spawn = uwsmApp [discord];};
      "Mod+e" = {action.spawn = uwsmApp ["nemo"];};
      # "Mod+n" = {action.spawn = uwsmApp ["swaync-client" "-t" "-sw"];};

      # Screenshots
      "Print" = {action.spawn = uwsmApp ["screenshot" "--copy"];};
      "Mod+Print" = {action.spawn = uwsmApp ["screenshot" "--save"];};

      # Focus movement
      "Mod+Left" = {action.focus-column-left = {};};
      "Mod+Right" = {action.focus-column-right = {};};
      "Mod+h" = {action.focus-column-left = {};};
      "Mod+l" = {action.focus-column-right = {};};
      "Mod+Up" = {action.focus-window-up = {};};
      "Mod+Down" = {action.focus-window-down = {};};

      # Workspaces 1-10
      "Mod+1" = {action.focus-workspace = [1];};
      "Mod+2" = {action.focus-workspace = [2];};
      "Mod+3" = {action.focus-workspace = [3];};
      "Mod+4" = {action.focus-workspace = [4];};
      "Mod+5" = {action.focus-workspace = [5];};
      "Mod+6" = {action.focus-workspace = [6];};
      "Mod+7" = {action.focus-workspace = [7];};
      "Mod+8" = {action.focus-workspace = [8];};
      "Mod+9" = {action.focus-workspace = [9];};
      "Mod+0" = {action.focus-workspace = [10];};

      # Move window to workspace
      "Mod+Shift+1" = {action.move-column-to-workspace = [1];};
      "Mod+Shift+2" = {action.move-column-to-workspace = [2];};
      "Mod+Shift+3" = {action.move-column-to-workspace = [3];};
      "Mod+Shift+4" = {action.move-column-to-workspace = [4];};
      "Mod+Shift+5" = {action.move-column-to-workspace = [5];};
      "Mod+Shift+6" = {action.move-column-to-workspace = [6];};
      "Mod+Shift+7" = {action.move-column-to-workspace = [7];};
      "Mod+Shift+8" = {action.move-column-to-workspace = [8];};
      "Mod+Shift+9" = {action.move-column-to-workspace = [9];};
      "Mod+Shift+0" = {action.move-column-to-workspace = [10];};

      # Change monitor focus
      "Mod+Tab" = {action.focus-monitor-next = {};};
      "Mod+Shift+Tab" = {action.focus-monitor-previous = {};};

      # Window movement
      "Mod+Shift+Left" = {action.move-column-left = {};};
      "Mod+Shift+Right" = {action.move-column-right = {};};

      # Media controls
      "XF86AudioPlay" = {action.spawn = uwsmApp ["playerctl" "play-pause"];};
      "XF86AudioNext" = {action.spawn = uwsmApp ["playerctl" "next"];};
      "XF86AudioPrev" = {action.spawn = uwsmApp ["playerctl" "previous"];};

      # Lock screen - hyprlock works on any Wayland compositor
      "Mod+g" = {action.spawn = uwsmApp ["hyprlock"];};

      # Logout menu
      "Mod+Escape" = {action.spawn = uwsmApp ["wlogout"];};
    };
  };
}
