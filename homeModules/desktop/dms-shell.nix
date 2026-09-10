{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.dms-shell;
  dmsPackage = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.dms-shell.overrideAttrs {
    vendorHash = "sha256-Ls6Dquwt0fzDCEjZ6FfTsZTXDI8408mFdByv/OWHVgI=";
  };
in {
  options.modules.desktop.dms-shell = {
    enable = lib.mkEnableOption "Enable DankMaterialShell";
  };
  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;

      package = dmsPackage;
      quickshell.package = pkgs.unstable.quickshell;
      # dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableVPN = true;

      systemd.enable = true;

      settings = {
        appIdSubstitutions = [];
        barConfigs = [
          {
            autoHide = false;
            autoHideDelay = 250;
            borderColor = "surfaceText";
            borderEnabled = false;
            borderOpacity = 1;
            borderThickness = 1;
            bottomGap = 0;
            centerWidgets = ["music" "clock" "weather"];
            clickThrough = false;
            enabled = true;
            fontScale = 1;
            gothCornerRadiusOverride = false;
            gothCornerRadiusValue = 12;
            gothCornersEnabled = false;
            iconScale = 1;
            id = "default";
            innerPadding = 4;
            leftWidgets = ["launcherButton" "workspaceSwitcher" "focusedWindow"];
            maximizeDetection = true;
            maximizeWidgetIcons = false;
            maximizeWidgetText = false;
            name = "Main Bar";
            noBackground = false;
            openOnOverview = true;
            popupGapsAuto = true;
            popupGapsManual = 4;
            position = 1;
            removeWidgetPadding = false;
            rightWidgets = [
              {
                enabled = true;
                id = "systemTray";
              }
              {
                enabled = true;
                id = "dankKDEConnect";
              }
              {
                enabled = true;
                id = "cpuUsage";
                minimumWidth = true;
              }
              {
                enabled = true;
                id = "memUsage";
                showSwap = false;
              }
              {
                enabled = true;
                id = "notificationButton";
              }
              {
                enabled = true;
                id = "battery";
              }
              {
                enabled = true;
                id = "controlCenterButton";
              }
              {
                enabled = true;
                id = "powerMenuButton";
              }
            ];
            screenPreferences = ["all"];
            scrollEnabled = true;
            scrollXBehavior = "column";
            scrollYBehavior = "workspace";
            shadowColorMode = "text";
            shadowCustomColor = "#000000";
            shadowIntensity = 0;
            shadowOpacity = 60;
            showOnLastDisplay = false;
            showOnWindowsOpen = false;
            spacing = 0;
            squareCorners = false;
            transparency = 1;
            visible = true;
            widgetOutlineColor = "primary";
            widgetOutlineEnabled = false;
            widgetOutlineOpacity = 1;
            widgetOutlineThickness = 1;
            widgetPadding = 8;
            widgetTransparency = 1;
          }
          {
            autoHide = false;
            autoHideDelay = 250;
            autoHideStrict = false;
            borderColor = "surfaceText";
            borderEnabled = false;
            borderOpacity = 1;
            borderThickness = 1;
            bottomGap = 0;
            centerWidgets = ["clock"];
            enabled = true;
            fontScale = 1;
            gothCornerRadiusOverride = false;
            gothCornerRadiusValue = 12;
            gothCornersEnabled = false;
            hoverPopoutDelay = 150;
            hoverPopouts = false;
            iconScale = 1;
            id = "bar1786832939320";
            innerPadding = 4;
            leftWidgets = ["launcherButton" "workspaceSwitcher" "focusedWindow"];
            maximizeDetection = true;
            maximizeWidgetIcons = false;
            maximizeWidgetText = false;
            name = "Bar 2";
            noBackground = false;
            openOnOverview = true;
            popupGapsAuto = true;
            popupGapsManual = 4;
            position = 1;
            removeWidgetPadding = false;
            rightWidgets = [
              {
                enabled = true;
                id = "systemTray";
              }
              {
                enabled = true;
                id = "cpuUsage";
                minimumWidth = true;
              }
              {
                enabled = true;
                id = "memUsage";
                showSwap = false;
              }
              {
                enabled = true;
                id = "notificationButton";
              }
              {
                enabled = true;
                id = "battery";
              }
              {
                enabled = true;
                id = "controlCenterButton";
              }
              {
                enabled = true;
                id = "powerMenuButton";
              }
            ];
            screenPreferences = ["all"];
            scrollEnabled = true;
            scrollXBehavior = "column";
            scrollYBehavior = "workspace";
            shadowColorMode = "text";
            shadowCustomColor = "#000000";
            shadowDirection = "top";
            shadowDirectionMode = "inherit";
            shadowIntensity = 0;
            shadowOpacity = 60;
            showOnLastDisplay = false;
            showOnWindowsOpen = false;
            spacing = 0;
            squareCorners = false;
            transparency = 1;
            useOverlayLayer = false;
            visible = false;
            widgetOutlineColor = "primary";
            widgetOutlineEnabled = false;
            widgetOutlineOpacity = 1;
            widgetOutlineThickness = 1;
            widgetPadding = 8;
            widgetTransparency = 1;
          }
        ];
        barElevationEnabled = false;
        builtInPluginSettings = {dms_settings_search = {trigger = "?";};};
        clipboardEnterToPaste = true;
        clockDateFormat = "ddd MMM d";
        configVersion = 18;
        controlCenterShowMicPercent = true;
        controlCenterWidgets = [
          {
            enabled = true;
            id = "volumeSlider";
            width = 50;
          }
          {
            enabled = true;
            id = "brightnessSlider";
            width = 50;
          }
          {
            enabled = true;
            id = "wifi";
            width = 50;
          }
          {
            enabled = true;
            id = "bluetooth";
            width = 50;
          }
          {
            enabled = true;
            id = "audioOutput";
            width = 50;
          }
          {
            enabled = true;
            id = "audioInput";
            width = 50;
          }
          {
            enabled = true;
            id = "doNotDisturb";
            width = 50;
          }
          {
            enabled = true;
            id = "darkMode";
            width = 25;
          }
          {
            enabled = true;
            id = "nightMode";
            width = 25;
          }
          {
            enabled = true;
            id = "idleInhibitor";
            width = 50;
          }
          {
            enabled = true;
            id = "diskUsage";
            instanceId = "mnxn7llost2cq7ne86zpf4lajm2w3";
            mountPath = "/";
            width = 50;
          }
        ];
        cornerRadius = 8;
        currentThemeCategory = "registry";
        currentThemeName = "custom";
        cursorSettings = {
          dwl = {cursorHideTimeout = 0;};
          hyprland = {
            hideOnKeyPress = false;
            hideOnTouch = false;
            inactiveTimeout = 0;
          };
          niri = {
            hideAfterInactiveMs = 0;
            hideWhenTyping = false;
          };
          size = 24;
          theme = "Bibata-Modern-Ice";
        };
        customThemeFile = "/home/elotoja/.config/DankMaterialShell/themes/catppuccin/theme.json";
        desktopClockCustomColor = {
          a = 1;
          b = 1;
          g = 1;
          hslHue = -1;
          hslLightness = 1;
          hslSaturation = 0;
          hsvHue = -1;
          hsvSaturation = 0;
          hsvValue = 1;
          r = 1;
          valid = true;
        };
        dockOpenOnOverview = true;
        dockPosition = 2;
        fontFamily = "JetBrainsMonoNL Nerd Font";
        lockDateFormat = "dddd, MMMM d";
        lockScreenNotificationMode = 2;
        matugenTemplateAlacritty = false;
        matugenTemplateEmacs = false;
        matugenTemplateEquibop = false;
        matugenTemplateFirefox = false;
        matugenTemplateFoot = false;
        matugenTemplateGhostty = false;
        matugenTemplateHyprland = false;
        matugenTemplateKitty = false;
        matugenTemplatePywalfox = false;
        matugenTemplateVesktop = false;
        matugenTemplateVscode = false;
        matugenTemplateWezterm = false;
        matugenTemplateZed = false;
        matugenTemplateZenBrowser = false;
        monoFontFamily = "JetBrainsMonoNL Nerd Font Mono";
        networkPreference = "wifi";
        osdAlwaysShowValue = true;
        osdPowerProfileEnabled = true;
        registryThemeVariants = {
          catppuccin = {
            dark = {
              accent = "blue";
              flavor = "mocha";
            };
            light = {
              accent = "blue";
              flavor = "latte";
            };
          };
        };
        screenPreferences = {wallpaper = ["all"];};
        showWorkspaceName = true;
        soundLogin = true;
        systemMonitorCustomColor = {
          a = 1;
          b = 1;
          g = 1;
          hslHue = -1;
          hslLightness = 1;
          hslSaturation = 0;
          hsvHue = -1;
          hsvSaturation = 0;
          hsvValue = 1;
          r = 1;
          valid = true;
        };
        terminalsAlwaysDark = true;
      };

      clipboardSettings = {
        autoClearDays = 1;
        clearAtStartup = true;
        disabled = false;
        maxEntrySize = 10485760;
        maxHistory = 25;
        maxPinned = 25;
      };

      plugins = {
        aiOverviewControl.enable = true;
        dankKDEConnect = {
          enable = true;
          settings.selectedDeviceId = "";
        };
        dankLauncherKeys = {
          enable = true;
          settings = {};
        };
      };
    };
    programs.dank-calendar = {
      enable = true;
      quickshell.package = pkgs.unstable.quickshell;
      systemd.enable = true;
    };
    wayland.windowManager.niri.settings.include = map (path: {_args = [path];}) [
      "dms/alttab.kdl"
      "dms/colors.kdl"
      # "dms/cursor.kdl"
      # "dms/layout.kdl"
      "dms/outputs.kdl"
      "dms/windowrules.kdl"
      # "dms/wpblur.kdl"
    ];
  };
}
