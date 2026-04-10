{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings.window-rules = [
      {
        matches = [
          {app-id = "^org.gnome.Nautilus$";}
          {app-id = "^.virt-manager-wrapped$";}
        ];
        default-column-width = {proportion = 0.5;};
      }

      # Floating applications
      {
        matches = [{app-id = "^audacious$";}];
        default-column-width = {proportion = 0.5;};
        open-floating = true;
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
            app-id = "^zen-beta$";
            title = ".*YouTube.*";
          }
        ];
        block-out-from = "screencast";
      }
      {
        matches = [
          {
            app-id = "^zen-beta$";
            title = ".*Bitwarden.*";
          }
        ];
        block-out-from = "screencast";
      }

      # https://github.com/sodiboo/niri-flake/pull/1382
      # {
      #   matches = [
      #     {app-id = "^zen-beta$";}
      #   ];
      #   open-maximized-to-edges = true;
      # }
      {
        matches = [
          {app-id = "^com.mitchellh.ghostty$";}
        ];
        open-maximized = true;
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
    ];
  };
}
