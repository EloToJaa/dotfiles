{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) discord;
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings.window-rules = [
      # Floating applications
      {
        matches = [{app-id = "^audacious$";}];
        default-column-width = {proportion = 0.5;};
        open-floating = true;
      }
      {
        matches = [{app-id = "^waypaper$";}];
        open-floating = true;
        open-on-workspace = "special:scratchpad";
      }
      {
        matches = [{app-id = "^org.pulseaudio.pavucontrol$";}];
        default-column-width = {fixed = 1200;};
        open-floating = true;
      }
      {
        matches = [{app-id = "^com.interversehq.qView$";}];
        open-floating = true;
      }
      {
        matches = [{app-id = "^nwg-displays$";}];
        default-column-width = {fixed = 1200;};
        open-floating = true;
      }
      {
        matches = [{app-id = "^mpv$";}];
        default-column-width = {fixed = 1200;};
        open-floating = true;
      }
      {
        matches = [
          {app-id = "^mpv$";}
          {app-id = "^.+exe$";}
          {app-id = "^celluloid$";}
        ];
        block-out-from = "screencast";
      }
      {
        matches = [
          {
            app-id = "^zen$";
            title = ".*YouTube.*";
          }
        ];
        block-out-from = "screencast";
      }

      # Picture-in-Picture
      {
        matches = [{title = "^Picture-in-Picture$";}];
        open-floating = true;
        open-on-workspace = "special:overlay";
      }

      # File chooser dialogs
      {
        matches = [
          {app-id = "^org.gnome.FileRoller$";}
          {app-id = "^file_progress$";}
          {app-id = "^confirm$";}
          {app-id = "^dialog$";}
          {app-id = "^download$";}
          {app-id = "^notification$";}
          {app-id = "^error$";}
          {app-id = "^confirmreset$";}
          {title = ".*Open File.*";}
          {title = ".*File Upload.*";}
          {title = "^branchdialog$";}
          {title = "^Confirm to replace files$";}
          {title = "^File Operation Progress$";}
          {title = ".*Bitwarden Password Manager.*";}
        ];
        open-floating = true;
      }

      # Screen sharing indicators - move to special workspace
      {
        matches = [
          {title = "^Firefox — Sharing Indicator$";}
          {title = "^Zen — Sharing Indicator$";}
          {title = ".*is sharing (your screen|a window)\.$";}
        ];
        open-on-workspace = "special:screencast";
      }

      # xwaylandvideobridge - hide completely
      {
        matches = [{app-id = "^xwaylandvideobridge$";}];
        open-floating = true;
        default-column-width = {fixed = 1;};
        default-window-height = {fixed = 1;};
      }

      # Workspace assignments
      {
        matches = [{app-id = "^zen-beta$";}];
        open-on-workspace = "1";
      }
      {
        matches = [
          {app-id = "^evince$";}
          {app-id = "^gimp$";}
        ];
        open-on-workspace = "4";
      }
      {
        matches = [
          {app-id = "^Audacious$";}
          {app-id = "^${discord}$";}
        ];
        open-on-workspace = "5";
      }
      {
        matches = [{app-id = "^Spotify$";}];
        open-on-workspace = "6";
      }
      {
        matches = [{app-id = "^com.obsproject.Studio$";}];
        open-on-workspace = "8";
      }
    ];
  };
}
