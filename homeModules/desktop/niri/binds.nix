{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) discord;
  cfg = config.modules.desktop.niri;

  screenshot_dir = "${config.home.homeDirectory}/Pictures/Screenshots";

  # Media and brightness keys keep working on the lockscreen.
  locked = spawn: {
    _props.allow-when-locked = true;
    inherit spawn;
  };

  noctaliaIpc = command: ["noctalia" "msg"] ++ command;
  # Noctalia has no scrolling capture, so the Alt variants capture a whole
  # output picked on screen. The target goes after the options.
  noctaliaScreenshotCommands = {
    region = {
      command = "screenshot-region";
      target = [];
    };
    window = {
      command = "screenshot-window";
      target = [];
    };
    full = {
      command = "screenshot-fullscreen";
      target = ["pick"];
    };
  };
  noctaliaScreenshotWith = options: mode: let
    inherit (noctaliaScreenshotCommands.${mode}) command target;
  in
    noctaliaIpc ([command "--no-annotate" "--save-to-file" "--directory" screenshot_dir] ++ options ++ target);
  noctaliaScreenshot = noctaliaScreenshotWith ["--copy-to-clipboard"];
  # Save the untouched original, then hand the capture to satty, which copies
  # and saves the edited version itself (see modules.desktop.satty).
  noctaliaScreenshotEdit = noctaliaScreenshotWith [
    "--no-copy-to-clipboard"
    "--pipe-to-command"
    "--pipe-command"
    "satty --filename -"
  ];

  # Noctalia has no process list, workspace rename or color picker.
  shellBinds = {
    "Mod+Shift+Slash".show-hotkey-overlay = {};
    "Mod+Shift+d".spawn = noctaliaIpc ["settings-toggle"];
    "Mod+Escape".spawn = noctaliaIpc ["panel-toggle" "session"];
    "Mod+a".spawn = noctaliaIpc ["panel-toggle" "control-center"];
    "Mod+n".spawn = noctaliaIpc ["panel-toggle" "control-center" "notifications"];
    "Mod+g".spawn = noctaliaIpc ["session" "lock"];
    "Mod+Shift+w".spawn = noctaliaIpc ["panel-toggle" "wallpaper"];
    "Mod+Space".spawn = noctaliaIpc ["panel-toggle" "launcher"];
    "Mod+Ctrl+e".spawn = noctaliaIpc ["panel-toggle" "launcher" "/emo "];
    "Mod+v".spawn = noctaliaIpc ["panel-toggle" "clipboard"];

    "XF86AudioRaiseVolume" = locked (noctaliaIpc ["volume-up" "2"]);
    "XF86AudioLowerVolume" = locked (noctaliaIpc ["volume-down" "2"]);
    "XF86AudioMute" = locked (noctaliaIpc ["volume-mute"]);
    "XF86AudioMicMute" = locked (noctaliaIpc ["mic-mute"]);
    "XF86AudioPause" = locked (noctaliaIpc ["media" "toggle"]);
    "XF86AudioPlay" = locked (noctaliaIpc ["media" "toggle"]);
    "XF86AudioPrev" = locked (noctaliaIpc ["media" "previous"]);
    "XF86AudioNext" = locked (noctaliaIpc ["media" "next"]);
    "Ctrl+XF86AudioRaiseVolume" = locked (noctaliaIpc ["media" "volume-up" "2"]);
    "Ctrl+XF86AudioLowerVolume" = locked (noctaliaIpc ["media" "volume-down" "2"]);
    "XF86MonBrightnessUp" = locked (noctaliaIpc ["brightness-up" "*" "5%"]);
    "XF86MonBrightnessDown" = locked (noctaliaIpc ["brightness-down" "*" "5%"]);

    "XF86Launch1".spawn = noctaliaScreenshot "region";
    "Ctrl+XF86Launch1".spawn = noctaliaScreenshot "window";
    "Alt+XF86Launch1".spawn = noctaliaScreenshot "full";
    "Mod+XF86Launch1".spawn = noctaliaScreenshotEdit "region";
    "Mod+Ctrl+XF86Launch1".spawn = noctaliaScreenshotEdit "window";
    "Mod+Alt+XF86Launch1".spawn = noctaliaScreenshotEdit "full";
    "Print".spawn = noctaliaScreenshot "region";
    "Ctrl+Print".spawn = noctaliaScreenshot "window";
    "Alt+Print".spawn = noctaliaScreenshot "full";
    "Mod+Print".spawn = noctaliaScreenshotEdit "region";
    "Mod+Ctrl+Print".spawn = noctaliaScreenshotEdit "window";
    "Mod+Alt+Print".spawn = noctaliaScreenshotEdit "full";
  };
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.niri.settings.binds =
      shellBinds
      // {
        "Mod+Tab" = {
          _props.repeat = false;
          toggle-overview = {};
        };
        "Mod+Shift+Tab".focus-monitor-previous = {};

        "Mod+p".spawn = ["sessionizer" "--desktop"];
        "Mod+Ctrl+p".spawn = ["machine-ssh" "--desktop"];
        "Mod+t".spawn = ["piper-toggle-clipboard"];
        "Mod+Shift+t".spawn = ["piper-stop-reading"];
        "Mod+d".spawn = [discord];
        "Mod+b".spawn = ["zen-beta"];
        "Mod+Shift+b".spawn = ["bar-visibility" "cycle"];
        "Mod+e".spawn = ["nautilus"];
        "Mod+s".spawn = ["spotify"];
        "Mod+Shift+Space".toggle-window-floating = {};

        "Mod+Return".spawn = ["ghostty" "+new-window"];
        "Mod+Comma".move-workspace-to-monitor-left = {};
        "Mod+Period".move-workspace-to-monitor-right = {};
        "Mod+Shift+n".spawn = ["gnome-text-editor"];
        "Mod+w".spawn = ["delfin"];

        "Mod+Shift+e".quit = {};

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

        # Mod+N targets the named workspaces from modules.desktop.niri workspaces.nix,
        # Mod+Alt+N keeps the positional index-based switching.
        "Mod+1".focus-workspace = ["w1"];
        "Mod+2".focus-workspace = ["w2"];
        "Mod+3".focus-workspace = ["w3"];
        "Mod+4".focus-workspace = ["w4"];
        "Mod+5".focus-workspace = ["w5"];
        "Mod+6".focus-workspace = ["w6"];

        "Mod+Shift+1".move-column-to-workspace = ["w1"];
        "Mod+Shift+2".move-column-to-workspace = ["w2"];
        "Mod+Shift+3".move-column-to-workspace = ["w3"];
        "Mod+Shift+4".move-column-to-workspace = ["w4"];
        "Mod+Shift+5".move-column-to-workspace = ["w5"];
        "Mod+Shift+6".move-column-to-workspace = ["w6"];

        "Mod+Alt+1".focus-workspace = [1];
        "Mod+Alt+2".focus-workspace = [2];
        "Mod+Alt+3".focus-workspace = [3];
        "Mod+Alt+4".focus-workspace = [4];
        "Mod+Alt+5".focus-workspace = [5];
        "Mod+Alt+6".focus-workspace = [6];
        "Mod+Alt+7".focus-workspace = [7];
        "Mod+Alt+8".focus-workspace = [8];
        "Mod+Alt+9".focus-workspace = [9];

        "Mod+Alt+Shift+1".move-column-to-workspace = [1];
        "Mod+Alt+Shift+2".move-column-to-workspace = [2];
        "Mod+Alt+Shift+3".move-column-to-workspace = [3];
        "Mod+Alt+Shift+4".move-column-to-workspace = [4];
        "Mod+Alt+Shift+5".move-column-to-workspace = [5];
        "Mod+Alt+Shift+6".move-column-to-workspace = [6];
        "Mod+Alt+Shift+7".move-column-to-workspace = [7];
        "Mod+Alt+Shift+8".move-column-to-workspace = [8];
        "Mod+Alt+Shift+9".move-column-to-workspace = [9];

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

        "Mod+o".spawn = ["screenshot-ocr"];
        "Mod+Shift+o".spawn = ["qr-capture"];

        "Mod+x".toggle-keyboard-shortcuts-inhibit = {};
        "Mod+Shift+p".power-off-monitors = {};
      };
  };
}
