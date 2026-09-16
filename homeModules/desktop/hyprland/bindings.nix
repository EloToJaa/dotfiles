{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) discord;
  cfg = config.modules.desktop.hyprland;
  dms = "dms ipc call";
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      bind = [
        # Applications and DMS. Keep these aligned with the niri bindings.
        "SUPER, P, exec, sessionizer --desktop"
        "SUPER CTRL, P, exec, machine-ssh --desktop"
        "SUPER CTRL, T, exec, piper-toggle-clipboard"
        "SUPER CTRL SHIFT, T, exec, piper-stop-reading"
        "SUPER, D, exec, ${discord}"
        "SUPER SHIFT, D, exec, ${dms} settings toggleWith displays"
        "SUPER, B, exec, zen-beta"
        "SUPER SHIFT, B, exec, bar-visibility cycle"
        "SUPER, E, exec, nautilus"
        "SUPER, Space, togglefloating"
        "SUPER SHIFT, S, exec, spotify"
        "SUPER, Return, exec, ghostty +new-window"
        "SUPER, S, exec, vicinae toggle"
        "SUPER CTRL, E, exec, vicinae vicinae://extensions/vicinae/search-emojis"
        "SUPER, V, exec, vicinae vicinae://launch/clipboard/history"
        "SUPER, M, exec, ${dms} processlist focusOrToggle"
        "SUPER, Escape, exec, ${dms} powermenu toggle"
        "SUPER, A, exec, ${dms} settings focusOrToggle"
        "SUPER, N, exec, ${dms} notifications toggle"
        "SUPER SHIFT, N, exec, gnome-text-editor"
        "SUPER, G, exec, ${dms} lock lock"
        "SUPER SHIFT, W, exec, ${dms} dash toggle wallpaper"
        "SUPER, W, exec, delfin"
        "SUPER SHIFT, Slash, exec, ${dms} keybinds toggle hyprland"
        "CTRL ALT, Delete, exec, ${dms} processlist focusOrToggle"
        "SUPER SHIFT, E, exit"

        # Window management.
        "SUPER, Q, killactive"
        "SUPER, F, fullscreen, 1"
        "SUPER SHIFT, F, fullscreen, 0"
        "SUPER SHIFT, V, exec, hyprctl dispatch cyclenext floating"
        "SUPER, Left, movefocus, l"
        "SUPER, Down, movefocus, d"
        "SUPER, Up, movefocus, u"
        "SUPER, Right, movefocus, r"
        "SUPER, H, movefocus, l"
        "SUPER, J, movefocus, d"
        "SUPER, K, movefocus, u"
        "SUPER, L, movefocus, r"
        "SUPER SHIFT, Left, movewindow, l"
        "SUPER SHIFT, Down, movewindow, d"
        "SUPER SHIFT, Up, movewindow, u"
        "SUPER SHIFT, Right, movewindow, r"
        "SUPER SHIFT, H, movewindow, l"
        "SUPER SHIFT, J, movewindow, d"
        "SUPER SHIFT, K, movewindow, u"
        "SUPER SHIFT, L, movewindow, r"

        # Monitors and workspaces.
        "SUPER CTRL, Left, focusmonitor, l"
        "SUPER CTRL, Right, focusmonitor, r"
        "SUPER CTRL, Up, focusmonitor, d"
        "SUPER CTRL, Down, focusmonitor, u"
        "SUPER CTRL, H, focusmonitor, l"
        "SUPER CTRL, J, focusmonitor, d"
        "SUPER CTRL, K, focusmonitor, u"
        "SUPER CTRL, L, focusmonitor, r"
        "SUPER CTRL SHIFT, Left, movewindow, mon:l"
        "SUPER CTRL SHIFT, Down, movewindow, mon:d"
        "SUPER CTRL SHIFT, Up, movewindow, mon:u"
        "SUPER CTRL SHIFT, Right, movewindow, mon:r"
        "SUPER CTRL SHIFT, H, movewindow, mon:l"
        "SUPER CTRL SHIFT, J, movewindow, mon:d"
        "SUPER CTRL SHIFT, K, movewindow, mon:u"
        "SUPER CTRL SHIFT, L, movewindow, mon:r"
        "SUPER, Comma, movecurrentworkspacetomonitor, l"
        "SUPER, Period, movecurrentworkspacetomonitor, r"
        "SUPER, Page_Down, workspace, e+1"
        "SUPER, Page_Up, workspace, e-1"
        "SUPER, U, workspace, e+1"
        "SUPER, I, workspace, e-1"
        "SUPER CTRL, U, movetoworkspace, e+1"
        "SUPER CTRL, I, movetoworkspace, e-1"
        "SUPER SHIFT, Page_Down, movetoworkspace, e+1"
        "SUPER SHIFT, Page_Up, movetoworkspace, e-1"
        "SUPER SHIFT, U, movetoworkspace, e+1"
        "SUPER SHIFT, I, movetoworkspace, e-1"
        "CTRL SHIFT, R, exec, ${dms} workspace-rename open"

        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"

        # Layout, screenshots, and display controls.
        "SUPER, R, togglesplit"
        "SUPER CTRL, F, fullscreen, 1"
        "SUPER, Minus, resizeactive, -100 0"
        "SUPER, Equal, resizeactive, 100 0"
        "SUPER SHIFT, Minus, resizeactive, 0 -100"
        "SUPER SHIFT, Equal, resizeactive, 0 100"
        ", Print, exec, dms screenshot"
        "CTRL, Print, exec, dms screenshot full"
        "ALT, Print, exec, dms screenshot window"
        ", XF86Launch1, exec, dms screenshot"
        "CTRL, XF86Launch1, exec, dms screenshot full"
        "ALT, XF86Launch1, exec, dms screenshot window"
        "SUPER, O, exec, ocr"
        "SUPER SHIFT, O, exec, qr-capture"
        "SUPER SHIFT, P, dpms, toggle"
      ];

      bindl = [
        ", XF86AudioMute, exec, ${dms} audio mute"
        ", XF86AudioMicMute, exec, ${dms} audio micmute"
        ", XF86AudioPause, exec, ${dms} mpris playPause"
        ", XF86AudioPlay, exec, ${dms} mpris playPause"
        ", XF86AudioPrev, exec, ${dms} mpris previous"
        ", XF86AudioNext, exec, ${dms} mpris next"
      ];

      bindle = [
        ", XF86AudioRaiseVolume, exec, ${dms} audio increment 2"
        ", XF86AudioLowerVolume, exec, ${dms} audio decrement 2"
        "CTRL, XF86AudioRaiseVolume, exec, ${dms} mpris increment 2"
        "CTRL, XF86AudioLowerVolume, exec, ${dms} mpris decrement 2"
        ", XF86MonBrightnessUp, exec, ${dms} brightness increment 5 ''"
        ", XF86MonBrightnessDown, exec, ${dms} brightness decrement 5 ''"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
}
