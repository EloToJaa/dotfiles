{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.niri.settings = {
      workspace = [
        {
          _args = ["terminal"];
          open-on-output = "DP-2";
        }
        {
          _args = ["browser"];
          open-on-output = "DP-1";
        }
        {
          _args = ["chat"];
          open-on-output = "HDMI-A-1";
        }
        {
          _args = ["watch"];
          open-on-output = "DP-2";
        }
        {
          _args = ["music"];
          open-on-output = "HDMI-A-1";
        }
        {
          _args = ["misc"];
          open-on-output = "DP-1";
        }
      ];
      window-rule = [
        {
          match._props.app-id._raw = ''r#"^zen-beta$"#'';
          open-on-workspace = "browser";
        }
        {
          match._props.app-id._raw = ''r#"^com.mitchellh.ghostty$"#'';
          open-on-workspace = "terminal";
        }
        {
          match._props.app-id._raw = ''r#"^vesktop$"#'';
          open-on-workspace = "chat";
        }
        {
          match._props.app-id._raw = ''r#"^spotify$"#'';
          open-on-workspace = "music";
        }
        {
          match._props.app-id._raw = ''r#"^com.obsproject.Studio$"#'';
          open-on-workspace = "misc";
        }
        {
          match._props.app-id._raw = ''r#"^cafe.avery.Delfin$"#'';
          open-on-workspace = "watch";
        }
      ];
    };
  };
}
