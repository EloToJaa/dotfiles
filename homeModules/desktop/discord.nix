{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) catppuccin;
  cfg = config.modules.desktop.discord;
in {
  options.modules.desktop.discord = {
    enable = lib.mkEnableOption "Enable discord";
  };
  config = lib.mkIf cfg.enable {
    # home.packages = with pkgs.unstable; [
    #   (discord.override {
    #     withVencord = true;
    #   })
    #   # webcord-vencord
    #   vesktop
    # ];

    programs.vesktop = {
      enable = true;
      package = pkgs.unstable.vesktop;
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

    xdg.configFile."Vencord/themes/custom.css".text =
      /*
      css
      */
      ''
        /**
         * @name Catppuccin
         * @author winston#0001
         * @authorId 505490445468696576
         * @version 0.2.0
         * @description 🎮 Soothing pastel theme for Discord
         * @website https://github.com/catppuccin/discord
         * @invite r6Mdz5dpFc
         * **/

        @import url("https://catppuccin.github.io/discord/dist/catppuccin-${catppuccin.flavor}.theme.css");
      '';
  };
}
