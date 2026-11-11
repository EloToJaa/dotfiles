{
  lib,
  config,
  pkgs,
  settings,
  ...
}: let
  inherit (settings) keyboardLayout discord;
  cfg = config.modules.desktop.umbriel;
  umbriel = config.programs.umbriel.package;

  screenshot_dir = "${config.home.homeDirectory}/Pictures/Screenshots";

  # Umbriel binds take a command line string run through the shell.
  spawn = args: "spawn ${lib.escapeShellArgs args}";
  noctalia = command: spawn (["noctalia" "msg"] ++ command);

  # Media and brightness keys keep working on the lockscreen.
  locked = {repeat ? true}: action: {
    inherit action repeat;
    allow_when_locked = true;
  };
  once = action: {
    inherit action;
    repeat = false;
  };
  cooldown = action: {
    inherit action;
    cooldown_ms = 150;
  };

  # The packaged config spells letter keys in uppercase ("Mod+Q"). Umbriel only
  # overrides an included bind with the exact same spelling, and reports "Mod+q"
  # as a duplicate that makes the config invalid, so match its case.
  normalizeKey = key: let
    parts = lib.splitString "+" key;
    keysym = lib.last parts;
  in
    lib.concatStringsSep "+" (lib.init parts
      ++ [
        (
          if lib.stringLength keysym == 1
          then lib.toUpper keysym
          else keysym
        )
      ]);

  # Noctalia has no scrolling capture, so the Alt variants capture a whole
  # output picked on screen. The target goes after the options.
  screenshotModes = {
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
  screenshotWith = options: mode: let
    inherit (screenshotModes.${mode}) command target;
  in
    noctalia ([command "--no-annotate" "--save-to-file" "--directory" screenshot_dir] ++ options ++ target);
  screenshot = screenshotWith ["--copy-to-clipboard"];
  # Save the untouched original, then hand the capture to satty, which copies
  # and saves the edited version itself (see modules.desktop.satty).
  screenshotEdit = screenshotWith [
    "--no-copy-to-clipboard"
    "--pipe-to-command"
    "--pipe-command"
    "satty --filename -"
  ];

  # Noctalia has no process list, workspace rename or color picker.
  shellBinds = {
    "Mod+Shift+Slash" = "cheatsheet-toggle";
    "Mod+Shift+d" = noctalia ["settings-toggle"];
    "Mod+Escape" = noctalia ["panel-toggle" "session"];
    "Mod+a" = noctalia ["panel-toggle" "control-center"];
    "Mod+n" = noctalia ["panel-toggle" "control-center" "notifications"];
    "Mod+g" = noctalia ["session" "lock"];
    "Mod+Shift+w" = noctalia ["panel-toggle" "wallpaper"];
    "Mod+Space" = noctalia ["panel-toggle" "launcher"];
    "Mod+Ctrl+e" = noctalia ["panel-toggle" "launcher" "/emo "];
    "Mod+v" = noctalia ["panel-toggle" "clipboard"];

    "XF86AudioRaiseVolume" = locked {} (noctalia ["volume-up" "2"]);
    "XF86AudioLowerVolume" = locked {} (noctalia ["volume-down" "2"]);
    "XF86AudioMute" = locked {repeat = false;} (noctalia ["volume-mute"]);
    "XF86AudioMicMute" = locked {repeat = false;} (noctalia ["mic-mute"]);
    "XF86AudioPause" = locked {repeat = false;} (noctalia ["media" "toggle"]);
    "XF86AudioPlay" = locked {repeat = false;} (noctalia ["media" "toggle"]);
    "XF86AudioPrev" = locked {repeat = false;} (noctalia ["media" "previous"]);
    "XF86AudioNext" = locked {repeat = false;} (noctalia ["media" "next"]);
    "Ctrl+XF86AudioRaiseVolume" = locked {} (noctalia ["media" "volume-up" "2"]);
    "Ctrl+XF86AudioLowerVolume" = locked {} (noctalia ["media" "volume-down" "2"]);
    "XF86MonBrightnessUp" = locked {} (noctalia ["brightness-up" "*" "5%"]);
    "XF86MonBrightnessDown" = locked {} (noctalia ["brightness-down" "*" "5%"]);

    "XF86Launch1" = screenshot "region";
    "Ctrl+XF86Launch1" = screenshot "window";
    "Alt+XF86Launch1" = screenshot "full";
    "Mod+XF86Launch1" = screenshotEdit "region";
    "Mod+Ctrl+XF86Launch1" = screenshotEdit "window";
    "Mod+Alt+XF86Launch1" = screenshotEdit "full";
    "Print" = screenshot "region";
    "Ctrl+Print" = screenshot "window";
    "Alt+Print" = screenshot "full";
    "Mod+Print" = screenshotEdit "region";
    "Mod+Ctrl+Print" = screenshotEdit "window";
    "Mod+Alt+Print" = screenshotEdit "full";
  };

  appBinds = {
    "Mod+p" = spawn ["sessionizer" "--desktop"];
    "Mod+Ctrl+p" = spawn ["machine-ssh" "--desktop"];
    "Mod+t" = spawn ["piper-toggle-clipboard"];
    "Mod+Shift+t" = spawn ["piper-stop-reading"];
    "Mod+d" = spawn [discord];
    "Mod+b" = spawn ["zen-beta"];
    "Mod+Shift+b" = spawn ["bar-visibility" "cycle"];
    "Mod+e" = spawn ["nautilus"];
    "Mod+s" = spawn ["spotify"];
    "Mod+Return" = once (spawn ["ghostty" "+new-window"]);
    "Mod+Shift+n" = spawn ["gnome-text-editor"];
    "Mod+w" = spawn ["delfin"];
    "Mod+o" = spawn ["screenshot-ocr"];
    "Mod+Shift+o" = spawn ["qr-capture"];
  };

  windowBinds = {
    "Mod+q" = once "window-close";
    "Mod+Shift+Space" = "window-toggle-floating";
    "Mod+Shift+v" = "window-focus-switch-floating";
    "Mod+f" = "window-toggle-maximize";
    "Mod+Shift+f" = "window-toggle-maximize-to-edges";
    # Niri expands the column to the available width here; fullscreen is the closest.
    "Mod+Ctrl+f" = once "window-toggle-fullscreen";
    "Mod+Shift+e" = "session-quit";
    "Mod+x" = {
      action = "shortcuts-inhibit-toggle";
      allow_when_inhibited = true;
      repeat = false;
    };
    "Mod+Shift+p" = "dpms-off";

    "Mod+BracketLeft" = "window-consume-or-expel-left";
    "Mod+BracketRight" = "window-consume-or-expel-right";

    "Mod+r" = "window-cycle-primary-extent";
    "Mod+Shift+r" = "window-cycle-secondary-extent";
    "Mod+c" = "column-center";
    "Mod+Minus" = "window-modify-primary-extent -0.1";
    "Mod+Equal" = "window-modify-primary-extent +0.1";
    "Mod+Shift+Minus" = "window-modify-secondary-extent -0.1";
    "Mod+Shift+Equal" = "window-modify-secondary-extent +0.1";
  };

  navigationBinds = {
    "Mod+Tab" = once "overview-toggle";
    "Mod+Shift+Tab" = "output-focus-previous";

    "Mod+Left" = "window-focus-or-output-left";
    "Mod+Down" = "window-focus-or-workspace-down";
    "Mod+Up" = "window-focus-or-workspace-up";
    "Mod+Right" = "window-focus-or-output-right";
    "Mod+h" = "window-focus-or-output-left";
    "Mod+j" = "window-focus-or-workspace-down";
    "Mod+k" = "window-focus-or-workspace-up";
    "Mod+l" = "window-focus-or-output-right";

    "Mod+Shift+Left" = "window-move-or-output-left";
    "Mod+Shift+Down" = "window-move-or-workspace-down";
    "Mod+Shift+Up" = "window-move-or-workspace-up";
    "Mod+Shift+Right" = "window-move-or-output-right";
    "Mod+Shift+h" = "window-move-or-output-left";
    "Mod+Shift+j" = "window-move-or-workspace-down";
    "Mod+Shift+k" = "window-move-or-workspace-up";
    "Mod+Shift+l" = "window-move-or-output-right";

    "Mod+Home" = "column-focus-first";
    "Mod+End" = "column-focus-last";
    "Mod+Ctrl+Home" = "column-move-to-first";
    "Mod+Ctrl+End" = "column-move-to-last";

    "Mod+Ctrl+Left" = "output-focus-left";
    "Mod+Ctrl+Right" = "output-focus-right";
    "Mod+Ctrl+Up" = "output-focus-up";
    "Mod+Ctrl+Down" = "output-focus-down";
    "Mod+Ctrl+h" = "output-focus-left";
    "Mod+Ctrl+j" = "output-focus-down";
    "Mod+Ctrl+k" = "output-focus-up";
    "Mod+Ctrl+l" = "output-focus-right";

    "Mod+Shift+Ctrl+Left" = "column-move-to-output-left";
    "Mod+Shift+Ctrl+Down" = "column-move-to-output-down";
    "Mod+Shift+Ctrl+Up" = "column-move-to-output-up";
    "Mod+Shift+Ctrl+Right" = "column-move-to-output-right";
    "Mod+Shift+Ctrl+h" = "column-move-to-output-left";
    "Mod+Shift+Ctrl+j" = "column-move-to-output-down";
    "Mod+Shift+Ctrl+k" = "column-move-to-output-up";
    "Mod+Shift+Ctrl+l" = "column-move-to-output-right";

    "Mod+Comma" = "workspace-move-to-output-left";
    "Mod+Period" = "workspace-move-to-output-right";

    "Mod+Page_Down" = "workspace-next";
    "Mod+Page_Up" = "workspace-previous";
    "Mod+u" = "workspace-next";
    "Mod+i" = "workspace-previous";
    "Mod+Ctrl+u" = "column-move-to-workspace-next";
    "Mod+Ctrl+i" = "column-move-to-workspace-previous";

    "Mod+Shift+Page_Down" = "workspace-move-down";
    "Mod+Shift+Page_Up" = "workspace-move-up";
    "Mod+Shift+u" = "workspace-move-down";
    "Mod+Shift+i" = "workspace-move-up";

    "Mod+WheelDown" = cooldown "workspace-next";
    "Mod+WheelUp" = cooldown "workspace-previous";
    "Mod+Ctrl+WheelDown" = cooldown "column-move-to-workspace-next";
    "Mod+Ctrl+WheelUp" = cooldown "column-move-to-workspace-previous";
    "Mod+WheelRight" = "window-focus-right";
    "Mod+WheelLeft" = "window-focus-left";
    "Mod+Ctrl+WheelRight" = "column-move-right";
    "Mod+Ctrl+WheelLeft" = "column-move-left";
    "Mod+Shift+WheelDown" = "window-focus-right";
    "Mod+Shift+WheelUp" = "window-focus-left";
    "Mod+Ctrl+Shift+WheelDown" = "column-move-right";
    "Mod+Ctrl+Shift+WheelUp" = "column-move-left";
  };

  # Mod+N targets the named workspaces below, Mod+Alt+N keeps the positional switching
  # (positions are per output, so it only reaches the first workspaces of each).
  named_workspaces = [
    {
      name = "w1"; # browser
      output = "DP-1";
    }
    {
      name = "w2"; # watch
      output = "DP-2";
    }
    {
      name = "w3"; # terminal
      output = "DP-2";
    }
    {
      name = "w4"; # misc
      output = "DP-1";
    }
    {
      name = "w5"; # chat
      output = "HDMI-A-1";
    }
    {
      name = "w6"; # music
      output = "HDMI-A-1";
    }
  ];
  numbers = lib.range 1 9;
  workspaceBinds = lib.listToAttrs (
    lib.concatMap (workspace: let
      inherit (workspace) name;
      key = lib.removePrefix "w" name;
    in [
      (lib.nameValuePair "Mod+${key}" "workspace-switch ${name}")
      (lib.nameValuePair "Mod+Shift+${key}" "column-move-to-workspace ${name}")
    ])
    named_workspaces
    ++ lib.concatMap (n: [
      (lib.nameValuePair "Mod+Alt+${toString n}" "workspace-switch ${toString n}")
      (lib.nameValuePair "Mod+Alt+Shift+${toString n}" "column-move-to-workspace ${toString n}")
    ])
    numbers
  );

  appWorkspaces = {
    "^zen-beta$" = "w1";
    "^com.mitchellh.ghostty$" = "w3";
    "^vesktop$" = "w5";
    "^spotify$" = "w6";
    "^com.jeffser.Nocturne$" = "w6";
    "^com.obsproject.Studio$" = "w4";
    "^cafe.avery.Delfin$" = "w2";
  };
  floatingApps = [
    "^winboat-.*"
    "^com.interversehq.qView$"
    "^org.pulseaudio.pavucontrol$"
    "^org.gnome.FileRoller$"
    "^file_progress$"
    "^confirm$"
    "^dialog$"
    "^download$"
    "^notification$"
    "^error$"
    "^confirmreset$"
  ];
in {
  options.modules.desktop.umbriel = {
    enable = lib.mkEnableOption "Enable umbriel";
  };

  config = lib.mkIf cfg.enable {
    # Umbriel is designed around the Noctalia shell, which it launches via its systemd user service
    modules.desktop.noctalia-shell.enable = lib.mkDefault true;

    programs.umbriel = {
      enable = true;
      # A user config replaces the packaged one, so include it to keep the default keybinds
      # (including the Noctalia launcher and media keys) and the Noctalia window and layer rules.
      settings = {
        include.files = ["${umbriel}/share/umbriel/config.toml"];

        general.autostart = map lib.escapeShellArgs [
          [(lib.getExe' pkgs.udiskie "udiskie") "--automount" "--notify" "--smart-tray"]
          [discord]
          [(lib.getExe pkgs.unstable.valent) "--gapplication-service"]
          [(lib.getExe pkgs.ntfy-sh) "subscribe" "--from-config"]
        ];

        input.keyboard = {
          layout = keyboardLayout;
          # Same as niri: Alt+Caps switches layout and Menu is the Compose key.
          options = "grp:alt_caps_toggle,compose:menu";
          numlock_toggle = true;
        };

        # Static workspaces, so they never get pruned or reordered.
        output =
          lib.mapAttrs (_: workspaces: {workspaces = map (workspace: workspace.name) workspaces;})
          (lib.groupBy (workspace: workspace.output) named_workspaces);

        general.show_cheatsheet = false;

        input.focus = {
          follows_mouse = true;
          hover_raises = false; # Hover only focuses, like niri
        };
        input.cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
          follows_focus = true; # Like niri's warp-mouse-to-focus
        };
        input.touchpad.natural_scroll = true;

        layout.gap = 2;
        appearance = {
          prefer_no_csd = true;
          border_width = 1;
          corner_radius = 8;
        };

        environment = {
          # Critical for electron apps
          NIXOS_OZONE_WL = "1";
          # Wayland/GTK theming
          GDK_BACKEND = "wayland";
          QT_QPA_PLATFORM = "wayland";
          MOZ_ENABLE_WAYLAND = "1";
          GTK_USE_PORTAL = "1";
        };

        # Keys set here override the packaged binds of the same name; the rest stay as defaults.
        keybinds =
          lib.mapAttrs' (key: lib.nameValuePair (normalizeKey key))
          (shellBinds // appBinds // windowBinds // navigationBinds // workspaceBinds);

        window_rule =
          lib.mapAttrsToList (app_id: workspace: {
            match.app_id = app_id;
            default_workspace = workspace;
          })
          appWorkspaces
          ++ [
            {
              match.app_id = floatingApps;
              default_floating = true;
            }
          ];
      };
    };
  };
}
