{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.niri.settings._children =
      (map (workspace: {workspace = workspace;}) [
        {
          _args = ["w1"]; # browser
          open-on-output = "DP-1";
        }
        {
          _args = ["w2"]; # watch
          open-on-output = "DP-2";
        }
        {
          _args = ["w3"]; # terminal
          open-on-output = "DP-2";
        }
        {
          _args = ["w4"]; # misc
          open-on-output = "DP-1";
        }
        {
          _args = ["w5"]; # chat
          open-on-output = "HDMI-A-1";
        }
        {
          _args = ["w6"]; # music
          open-on-output = "HDMI-A-1";
        }
      ])
      ++ (map (rule: {window-rule = rule;}) [
        {
          match._props.app-id = "^zen-beta$";
          open-on-workspace = "w1";
        }
        {
          match._props.app-id = "^com.mitchellh.ghostty$";
          open-on-workspace = "w3";
        }
        {
          match._props.app-id = "^vesktop$";
          open-on-workspace = "w5";
        }
        {
          match._props.app-id = "^spotify$";
          open-on-workspace = "w6";
        }
        {
          match._props.app-id = "^com.jeffser.Nocturne$";
          open-on-workspace = "w6";
        }
        {
          match._props.app-id = "^com.obsproject.Studio$";
          open-on-workspace = "w4";
        }
        {
          match._props.app-id = "^cafe.avery.Delfin$";
          open-on-workspace = "w2";
        }
      ]);
  };
}
