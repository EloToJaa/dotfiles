{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) discord;
  cfg = config.modules.desktop.niri;

  dmsIpc = command: ["dms" "ipc" "call"] ++ command;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings.binds = {
      "Mod+Tab" = {
        repeat = false;
        action.toggle-overview = {};
      };
      "Mod+Shift+Tab".action.focus-monitor-previous = {};
      "Mod+Shift+Slash" = {
        hotkey-overlay.title = "Show Hotkey Overlay";
        action.spawn = dmsIpc ["keybinds" "toggle" "niri"];
      };

      "Mod+p" = {
        hotkey-overlay.title = "Open project in ghostty";
        action.spawn = ["sessionizer"];
      };
      "Mod+d" = {
        hotkey-overlay.title = "Discord";
        action.spawn = [discord];
      };
      "Mod+Shift+d" = {
        hotkey-overlay.title = "Display settings";
        action.spawn = dmsIpc ["settings" "toggleWith" "displays"];
      };
      "Mod+b" = {
        hotkey-overlay.title = "Zen Browser";
        action.spawn = ["zen-beta"];
      };
      "Mod+e" = {
        hotkey-overlay.title = "Nautilus file manager";
        action.spawn = ["nautilus"];
      };
      "Mod+Space" = {
        hotkey-overlay.title = "Window Floating";
        action.toggle-window-floating = {};
      };
      "Mod+Shift+s" = {
        hotkey-overlay.title = "Spotify";
        action.spawn = ["spotify"];
      };

      "Mod+Return" = {
        hotkey-overlay.title = "Open Terminal";
        action.spawn = ["ghostty" "+new-window"];
      };
      "Mod+s" = {
        hotkey-overlay.title = "Application Launcher";
        action.spawn = ["vicinae" "toggle"];
      };
      "Mod+v" = {
        hotkey-overlay.title = "Clipboard Manager";
        action.spawn = ["vicinae" "vicinae://extensions/vicinae/clipboard/history"];
      };
      "Mod+m" = {
        hotkey-overlay.title = "Task Manager";
        action.spawn = dmsIpc ["processlist" "focusOrToggle"];
      };
      "Mod+Escape" = {
        hotkey-overlay.title = "Power Menu: Toggle";
        action.spawn = dmsIpc ["powermenu" "toggle"];
      };
      "Mod+a" = {
        hotkey-overlay.title = "Settings";
        action.spawn = dmsIpc ["settings" "focusOrToggle"];
      };
      "Mod+Comma".action.move-workspace-to-monitor-left = {};
      "Mod+Period".action.move-workspace-to-monitor-right = {};
      "Mod+n" = {
        hotkey-overlay.title = "Notifications";
        action.spawn = dmsIpc ["notifications" "toggle"];
      };
      "Mod+Shift+n" = {
        hotkey-overlay.title = "Notepad";
        action.spawn = ["gnome-text-editor"];
      };
      "Mod+g" = {
        hotkey-overlay.title = "Lock Screen";
        action.spawn = dmsIpc ["lock" "lock"];
      };
      "Mod+Shift+w" = {
        hotkey-overlay.title = "Browse wallpaper";
        action.spawn = dmsIpc ["dankdash" "wallpaper"];
      };
      "Mod+w" = {
        hotkey-overlay.title = "Launch jellyfin app";
        action.spawn = ["delfin"];
      };

      "Mod+Shift+e".action.quit = {};

      "Ctrl+Alt+Delete" = {
        hotkey-overlay.title = "Task Manager";
        action.spawn = dmsIpc ["processlist" "focusOrToggle"];
      };

      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["audio" "increment" "2"];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["audio" "decrement" "2"];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["audio" "mute"];
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["audio" "micmute"];
      };
      "XF86AudioPause" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["mpris" "playPause"];
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["mpris" "playPause"];
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["mpris" "previous"];
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["mpris" "next"];
      };
      "Ctrl+XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["mpris" "increment" "2"];
      };
      "Ctrl+XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["mpris" "decrement" "2"];
      };

      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["brightness" "increment" "5" ""];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = dmsIpc ["brightness" "decrement" "5" ""];
      };

      "Mod+q" = {
        repeat = false;
        action.close-window = {};
      };
      "Mod+f".action.maximize-column = {};
      "Mod+Shift+f".action.maximize-window-to-edges = {};
      # "Mod+Shift+f".action.fullscreen-window = {};
      "Mod+Shift+v".action.switch-focus-between-floating-and-tiling = {};

      "Mod+Left".action.focus-column-or-monitor-left = {};
      "Mod+Down".action.focus-window-or-workspace-down = {};
      "Mod+Up".action.focus-window-or-workspace-up = {};
      "Mod+Right".action.focus-column-or-monitor-right = {};
      "Mod+h".action.focus-column-or-monitor-left = {};
      "Mod+j".action.focus-window-or-workspace-down = {};
      "Mod+k".action.focus-window-or-workspace-up = {};
      "Mod+l".action.focus-column-or-monitor-right = {};

      "Mod+Shift+Left".action.move-column-left-or-to-monitor-left = {};
      "Mod+Shift+Down".action.move-window-down-or-to-workspace-down = {};
      "Mod+Shift+Up".action.move-window-up-or-to-workspace-up = {};
      "Mod+Shift+Right".action.move-column-right-or-to-monitor-right = {};
      "Mod+Shift+h".action.move-column-left-or-to-monitor-left = {};
      "Mod+Shift+j".action.move-window-down-or-to-workspace-down = {};
      "Mod+Shift+k".action.move-window-up-or-to-workspace-up = {};
      "Mod+Shift+l".action.move-column-right-or-to-monitor-right = {};

      "Mod+Home".action.focus-column-first = {};
      "Mod+End".action.focus-column-last = {};
      "Mod+Ctrl+Home".action.move-column-to-first = {};
      "Mod+Ctrl+End".action.move-column-to-last = {};

      "Mod+Ctrl+Left".action.focus-monitor-left = {};
      "Mod+Ctrl+Right".action.focus-monitor-right = {};
      "Mod+Ctrl+Up".action.focus-monitor-down = {};
      "Mod+Ctrl+Down".action.focus-monitor-up = {};
      "Mod+Ctrl+h".action.focus-monitor-left = {};
      "Mod+Ctrl+j".action.focus-monitor-down = {};
      "Mod+Ctrl+k".action.focus-monitor-up = {};
      "Mod+Ctrl+l".action.focus-monitor-right = {};

      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = {};
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = {};
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = {};
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = {};
      "Mod+Shift+Ctrl+h".action.move-column-to-monitor-left = {};
      "Mod+Shift+Ctrl+j".action.move-column-to-monitor-down = {};
      "Mod+Shift+Ctrl+k".action.move-column-to-monitor-up = {};
      "Mod+Shift+Ctrl+l".action.move-column-to-monitor-right = {};

      "Mod+Page_Down".action.focus-workspace-down = {};
      "Mod+Page_Up".action.focus-workspace-up = {};
      "Mod+u".action.focus-workspace-down = {};
      "Mod+i".action.focus-workspace-up = {};
      "Mod+Ctrl+u".action.move-column-to-workspace-down = {};
      "Mod+Ctrl+i".action.move-column-to-workspace-up = {};

      "Ctrl+Shift+r" = {
        hotkey-overlay.title = "Rename Workspace";
        action.spawn = dmsIpc ["workspace-rename" "open"];
      };

      "Mod+Shift+Page_Down".action.move-workspace-down = {};
      "Mod+Shift+Page_Up".action.move-workspace-up = {};
      "Mod+Shift+u".action.move-workspace-down = {};
      "Mod+Shift+i".action.move-workspace-up = {};

      "Mod+WheelScrollDown" = {
        "cooldown-ms" = 150;
        action.focus-workspace-down = {};
      };
      "Mod+WheelScrollUp" = {
        "cooldown-ms" = 150;
        action.focus-workspace-up = {};
      };
      "Mod+Ctrl+WheelScrollDown" = {
        "cooldown-ms" = 150;
        action.move-column-to-workspace-down = {};
      };
      "Mod+Ctrl+WheelScrollUp" = {
        "cooldown-ms" = 150;
        action.move-column-to-workspace-up = {};
      };
      "Mod+WheelScrollRight".action.focus-column-right = {};
      "Mod+WheelScrollLeft".action.focus-column-left = {};
      "Mod+Ctrl+WheelScrollRight".action.move-column-right = {};
      "Mod+Ctrl+WheelScrollLeft".action.move-column-left = {};
      "Mod+Shift+WheelScrollDown".action.focus-column-right = {};
      "Mod+Shift+WheelScrollUp".action.focus-column-left = {};
      "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = {};
      "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = {};

      "Mod+1".action.focus-workspace = [1];
      "Mod+2".action.focus-workspace = [2];
      "Mod+3".action.focus-workspace = [3];
      "Mod+4".action.focus-workspace = [4];
      "Mod+5".action.focus-workspace = [5];
      "Mod+6".action.focus-workspace = [6];
      "Mod+7".action.focus-workspace = [7];
      "Mod+8".action.focus-workspace = [8];
      "Mod+9".action.focus-workspace = [9];

      "Mod+Shift+1".action.move-column-to-workspace = [1];
      "Mod+Shift+2".action.move-column-to-workspace = [2];
      "Mod+Shift+3".action.move-column-to-workspace = [3];
      "Mod+Shift+4".action.move-column-to-workspace = [4];
      "Mod+Shift+5".action.move-column-to-workspace = [5];
      "Mod+Shift+6".action.move-column-to-workspace = [6];
      "Mod+Shift+7".action.move-column-to-workspace = [7];
      "Mod+Shift+8".action.move-column-to-workspace = [8];
      "Mod+Shift+9".action.move-column-to-workspace = [9];

      "Mod+BracketLeft".action.consume-or-expel-window-left = {};
      "Mod+BracketRight".action.consume-or-expel-window-right = {};
      # "Mod+Period".action.expel-window-from-column = {};

      "Mod+r".action.switch-preset-column-width = {};
      "Mod+Shift+r".action.switch-preset-window-height = {};
      "Mod+Ctrl+r".action.reset-window-height = {};
      "Mod+Ctrl+f".action.expand-column-to-available-width = {};
      "Mod+c".action.center-column = {};
      "Mod+Ctrl+c".action.center-visible-columns = {};

      "Mod+Minus".action.set-column-width = ["-10%"];
      "Mod+Equal".action.set-column-width = ["+10%"];
      "Mod+Shift+Minus".action.set-window-height = ["-10%"];
      "Mod+Shift+Equal".action.set-window-height = ["+10%"];

      "XF86Launch1".action.spawn = dmsIpc ["niri" "screenshot"];
      "Ctrl+XF86Launch1".action.spawn = dmsIpc ["niri" "screenshotScreen"];
      "Alt+XF86Launch1".action.spawn = dmsIpc ["niri" "screenshotWindow"];
      "Print".action.spawn = dmsIpc ["niri" "screenshot"];
      "Ctrl+Print".action.spawn = dmsIpc ["niri" "screenshotScreen"];
      "Alt+Print".action.spawn = dmsIpc ["niri" "screenshotWindow"];
      "Mod+o".action.spawn = ["ocr"];

      "Mod+x".action.toggle-keyboard-shortcuts-inhibit = {};
      "Mod+Shift+p".action.power-off-monitors = {};
    };
  };
}
