{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.discord;
in {
  options.modules.desktop.discord = {
    enable = lib.mkEnableOption "Enable discord";
  };
  config = lib.mkIf cfg.enable {
    programs.vesktop = {
      enable = true;
      package = pkgs.master.vesktop;
      settings = {
        appBadge = false;
        arRPC = true;
        checkUpdates = false;
        customTitleBar = false;
        disableMinSize = true;
        minimizeToTray = true;
        tray = true;
        splashBackground = "#000000";
        splashColor = "#ffffff";
        splashTheming = true;
        staticTitle = true;
        hardwareAcceleration = true;
        discordBranch = "stable";
      };
      vencord = {
        useSystem = true;
        settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          notifyAboutUpdates = false;

          useQuickCss = true;
          themeLinks = [];
          eagerPatches = false;
          enableReactDevtools = true;
          frameless = false;
          transparent = true;
          winCtrlQ = false;
          disableMinSize = true;
          winNativeTitleBar = false;

          plugins = {
            MessageLogger = {
              enabled = true;
              ignoreSelf = true;
            };
            FakeNitro.enabled = true;
            CommandsAPI.enabled = true;
            MessageAccessoriesAPI.enabled = true;
            UserSettingsAPI.enabled = true;
            AlwaysExpandRoles.enabled = true;
            AlwaysTrust.enabled = true;
            BetterSessions.enabled = true;
            CrashHandler.enabled = true;
            FixImagesQuality.enabled = true;
            FixSpotifyEmbeds.enabled = true;
            PlatformIndicators.enabled = true;
            ReplyTimestamp.enabled = true;
            ShowHiddenChannels.enabled = true;
            ShowHiddenThings.enabled = true;
            VencordToolbox.enabled = true;
            WebKeybinds.enabled = true;
            WebScreenShareFixes.enabled = true;
            YoutubeAdblock.enabled = true;
            BadgeAPI.enabled = true;
            NoTrack = {
              enabled = true;
              disableAnalytics = true;
            };
            Settings = {
              enabled = true;
              settingsLocation = "aboveNitro";
            };
          };

          notifications = {
            timeout = 5000;
            position = "bottom-right";
            useNative = "not-focused";
            logLimit = 50;
          };
        };
      };
    };
  };
}
