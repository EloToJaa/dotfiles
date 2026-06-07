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
    wayland.windowManager.niri.settings.binds = {
      "Mod+Tab" = {
        _props.repeat = false;
        toggle-overview = {};
      };
      "Mod+Shift+Tab".focus-monitor-previous = {};
      "Mod+Shift+Slash".spawn = dmsIpc ["keybinds" "toggle" "niri"];

      "Mod+p".spawn = ["sessionizer"];
      "Mod+d".spawn = [discord];
      "Mod+Shift+d".spawn = dmsIpc ["settings" "toggleWith" "displays"];
      "Mod+b".spawn = ["zen-beta"];
      "Mod+e".spawn = ["nautilus"];
      "Mod+Space".toggle-window-floating = {};
      "Mod+Shift+s".spawn = ["spotify"];

      "Mod+Return".spawn = ["ghostty" "+new-window"];
      "Mod+s".spawn = ["vicinae" "toggle"];
      "Mod+v".spawn = ["vicinae" "vicinae://launch/clipboard/history"];
      "Mod+m".spawn = dmsIpc ["processlist" "focusOrToggle"];
      "Mod+Escape".spawn = dmsIpc ["powermenu" "toggle"];
      "Mod+a".spawn = dmsIpc ["settings" "focusOrToggle"];
      "Mod+Comma".move-workspace-to-monitor-left = {};
      "Mod+Period".move-workspace-to-monitor-right = {};
      "Mod+n".spawn = dmsIpc ["notifications" "toggle"];
      "Mod+Shift+n".spawn = ["gnome-text-editor"];
      "Mod+g".spawn = dmsIpc ["lock" "lock"];
      "Mod+Shift+w".spawn = dmsIpc ["dankdash" "wallpaper"];
      "Mod+w".spawn = ["delfin"];

      "Mod+Shift+e".quit = {};
      "Ctrl+Alt+Delete".spawn = dmsIpc ["processlist" "focusOrToggle"];

      "XF86AudioRaiseVolume" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["audio" "increment" "2"];
      };
      "XF86AudioLowerVolume" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["audio" "decrement" "2"];
      };
      "XF86AudioMute" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["audio" "mute"];
      };
      "XF86AudioMicMute" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["audio" "micmute"];
      };
      "XF86AudioPause" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["mpris" "playPause"];
      };
      "XF86AudioPlay" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["mpris" "playPause"];
      };
      "XF86AudioPrev" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["mpris" "previous"];
      };
      "XF86AudioNext" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["mpris" "next"];
      };
      "Ctrl+XF86AudioRaiseVolume" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["mpris" "increment" "2"];
      };
      "Ctrl+XF86AudioLowerVolume" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["mpris" "decrement" "2"];
      };

      "XF86MonBrightnessUp" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["brightness" "increment" "5" ""];
      };
      "XF86MonBrightnessDown" = {
        _props.allow-when-locked = true;
        spawn = dmsIpc ["brightness" "decrement" "5" ""];
      };

      "Mod+q" = {
        _props.repeat = false;
        close-window = {};
      };
      "Mod+f".maximize-column = {};
      "Mod+Shift+f".maximize-window-to-edges = {};
      # "Mod+Shift+f".fullscreen-window = {};
      "Mod+Shift+v".switch-focus-between-floating-and-tiling = {};

      "Mod+Left".focus-column-or-monitor-left = {};
      "Mod+Down".focus-window-or-workspace-down = {};
      "Mod+Up".focus-window-or-workspace-up = {};
      "Mod+Right".focus-column-or-monitor-right = {};
      "Mod+h".focus-column-or-monitor-left = {};
      "Mod+j".focus-window-or-workspace-down = {};
      "Mod+k".focus-window-or-workspace-up = {};
      "Mod+l".focus-column-or-monitor-right = {};

      "Mod+Shift+Left".move-column-left-or-to-monitor-left = {};
      "Mod+Shift+Down".move-window-down-or-to-workspace-down = {};
      "Mod+Shift+Up".move-window-up-or-to-workspace-up = {};
      "Mod+Shift+Right".move-column-right-or-to-monitor-right = {};
      "Mod+Shift+h".move-column-left-or-to-monitor-left = {};
      "Mod+Shift+j".move-window-down-or-to-workspace-down = {};
      "Mod+Shift+k".move-window-up-or-to-workspace-up = {};
      "Mod+Shift+l".move-column-right-or-to-monitor-right = {};

      "Mod+Home".focus-column-first = {};
      "Mod+End".focus-column-last = {};
      "Mod+Ctrl+Home".move-column-to-first = {};
      "Mod+Ctrl+End".move-column-to-last = {};

      "Mod+Ctrl+Left".focus-monitor-left = {};
      "Mod+Ctrl+Right".focus-monitor-right = {};
      "Mod+Ctrl+Up".focus-monitor-down = {};
      "Mod+Ctrl+Down".focus-monitor-up = {};
      "Mod+Ctrl+h".focus-monitor-left = {};
      "Mod+Ctrl+j".focus-monitor-down = {};
      "Mod+Ctrl+k".focus-monitor-up = {};
      "Mod+Ctrl+l".focus-monitor-right = {};

      "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = {};
      "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = {};
      "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = {};
      "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = {};
      "Mod+Shift+Ctrl+h".move-column-to-monitor-left = {};
      "Mod+Shift+Ctrl+j".move-column-to-monitor-down = {};
      "Mod+Shift+Ctrl+k".move-column-to-monitor-up = {};
      "Mod+Shift+Ctrl+l".move-column-to-monitor-right = {};

      "Mod+Page_Down".focus-workspace-down = {};
      "Mod+Page_Up".focus-workspace-up = {};
      "Mod+u".focus-workspace-down = {};
      "Mod+i".focus-workspace-up = {};
      "Mod+Ctrl+u".move-column-to-workspace-down = {};
      "Mod+Ctrl+i".move-column-to-workspace-up = {};
      "Ctrl+Shift+r".spawn = dmsIpc ["workspace-rename" "open"];

      "Mod+Shift+Page_Down".move-workspace-down = {};
      "Mod+Shift+Page_Up".move-workspace-up = {};
      "Mod+Shift+u".move-workspace-down = {};
      "Mod+Shift+i".move-workspace-up = {};

      "Mod+WheelScrollDown" = {
        _props.cooldown-ms = 150;
        focus-workspace-down = {};
      };
      "Mod+WheelScrollUp" = {
        _props.cooldown-ms = 150;
        focus-workspace-up = {};
      };
      "Mod+Ctrl+WheelScrollDown" = {
        _props.cooldown-ms = 150;
        move-column-to-workspace-down = {};
      };
      "Mod+Ctrl+WheelScrollUp" = {
        _props.cooldown-ms = 150;
        move-column-to-workspace-up = {};
      };
      "Mod+WheelScrollRight".focus-column-right = {};
      "Mod+WheelScrollLeft".focus-column-left = {};
      "Mod+Ctrl+WheelScrollRight".move-column-right = {};
      "Mod+Ctrl+WheelScrollLeft".move-column-left = {};
      "Mod+Shift+WheelScrollDown".focus-column-right = {};
      "Mod+Shift+WheelScrollUp".focus-column-left = {};
      "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = {};
      "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = {};

      "Mod+1".focus-workspace = [1];
      "Mod+2".focus-workspace = [2];
      "Mod+3".focus-workspace = [3];
      "Mod+4".focus-workspace = [4];
      "Mod+5".focus-workspace = [5];
      "Mod+6".focus-workspace = [6];
      "Mod+7".focus-workspace = [7];
      "Mod+8".focus-workspace = [8];
      "Mod+9".focus-workspace = [9];

      "Mod+Shift+1".move-column-to-workspace = [1];
      "Mod+Shift+2".move-column-to-workspace = [2];
      "Mod+Shift+3".move-column-to-workspace = [3];
      "Mod+Shift+4".move-column-to-workspace = [4];
      "Mod+Shift+5".move-column-to-workspace = [5];
      "Mod+Shift+6".move-column-to-workspace = [6];
      "Mod+Shift+7".move-column-to-workspace = [7];
      "Mod+Shift+8".move-column-to-workspace = [8];
      "Mod+Shift+9".move-column-to-workspace = [9];

      "Mod+BracketLeft".consume-or-expel-window-left = {};
      "Mod+BracketRight".consume-or-expel-window-right = {};
      # "Mod+Period".expel-window-from-column = {};

      "Mod+r".switch-preset-column-width = {};
      "Mod+Shift+r".switch-preset-window-height = {};
      "Mod+Ctrl+r".reset-window-height = {};
      "Mod+Ctrl+f".expand-column-to-available-width = {};
      "Mod+c".center-column = {};
      "Mod+Ctrl+c".center-visible-columns = {};

      "Mod+Minus".set-column-width = ["-10%"];
      "Mod+Equal".set-column-width = ["+10%"];
      "Mod+Shift+Minus".set-window-height = ["-10%"];
      "Mod+Shift+Equal".set-window-height = ["+10%"];

      "XF86Launch1".spawn = dmsIpc ["niri" "screenshot"];
      "Ctrl+XF86Launch1".spawn = dmsIpc ["niri" "screenshotScreen"];
      "Alt+XF86Launch1".spawn = dmsIpc ["niri" "screenshotWindow"];
      "Print".spawn = dmsIpc ["niri" "screenshot"];
      "Ctrl+Print".spawn = dmsIpc ["niri" "screenshotScreen"];
      "Alt+Print".spawn = dmsIpc ["niri" "screenshotWindow"];
      "Mod+o".spawn = ["ocr"];

      "Mod+x".toggle-keyboard-shortcuts-inhibit = {};
      "Mod+Shift+p".power-off-monitors = {};
    };
  };
}
