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
          open-on-output = "DP-1";
          name = "terminal";
        };
        "02-browser" = {
          open-on-output = "DP-1";
          name = "browser";
        };
        "03-chat" = {
          open-on-output = "DP-1";
          name = "chat";
        };
        "04-watch" = {
          open-on-output = "DP-1";
          name = "watch";
        };
        "05-music" = {
          open-on-output = "DP-1";
          name = "music";
        };
        "06-record" = {
          open-on-output = "DP-1";
          name = "record";
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
            {app-id = "^ghostty$";}
          ];
          open-on-workspace = "terminal";
        }
        {
          matches = [
            {app-id = "^vesktop$";}
          ];
          open-on-workspace = "chat";
        }
      ];
    };
  };
}
