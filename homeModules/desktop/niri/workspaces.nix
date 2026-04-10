{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings = {
      workspaces = {
        "01-terminal" = {
          open-on-output = "DP-2";
          name = "terminal";
        };
        "02-browser" = {
          open-on-output = "DP-1";
          name = "browser";
        };
        "03-chat" = {
          open-on-output = "HDMI-A-1";
          name = "chat";
        };
        "04-watch" = {
          open-on-output = "DP-2";
          name = "watch";
        };
        "05-music" = {
          open-on-output = "HDMI-A-1";
          name = "music";
        };
        "06-misc" = {
          open-on-output = "DP-1";
          name = "misc";
        };
      };
      window-rules = [
        {
          matches = [
            {app-id = "^zen-beta$";}
          ];
          open-on-workspace = "browser";
        }
        {
          matches = [
            {app-id = "^com.mitchellh.ghostty$";}
          ];
          open-on-workspace = "terminal";
        }
        {
          matches = [
            {app-id = "^vesktop$";}
          ];
          open-on-workspace = "chat";
        }
        {
          matches = [
            {app-id = "^spotify$";}
          ];
          open-on-workspace = "music";
        }
        {
          matches = [
            {app-id = "^com.obsproject.Studio$";}
          ];
          open-on-workspace = "misc";
        }
        {
          matches = [
            {app-id = "^cafe.avery.Delfin$";}
          ];
          open-on-workspace = "watch";
        }
      ];
    };
  };
}
