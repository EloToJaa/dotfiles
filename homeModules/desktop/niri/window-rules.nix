{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.niri.settings._children = map (rule: {window-rule = rule;}) [
      {
        geometry-corner-radius = 8.0;
        clip-to-geometry = true;
        tiled-state = true;
        draw-border-with-background = false;
      }
      {
        match._props.app-id = "^winboat$";
        # clip-to-geometry = false;
        # tiled-state = false;
        # border.enable = false;
        # focus-ring.enable = false;
      }
      {
        match._props.app-id = "^winboat-.*";
        clip-to-geometry = false;
        tiled-state = false;
        open-floating = true;
        # border.enable = false;
        # focus-ring.enable = false;
      }
      {
        match._children = [
          {_props.app-id = "^org.gnome.Nautilus$";}
          {_props.app-id = "^org.gnome.TextEditor$";}
          {_props.app-id = "^org.gnome.Papers$";}
          {_props.app-id = "^.virt-manager-wrapped$";}
        ];
        default-column-width.proportion = 0.5;
      }

      # Floating applications
      {
        match._props = {
          app-id = "^audacious$";
          title = ".*Bitwarden Password Manager.*";
        };
        default-column-width.proportion = 0.5;
        open-floating = true;
      }
      {
        match._props.app-id = "^org.pulseaudio.pavucontrol$";
        default-column-width.fixed = 1200;
        open-floating = true;
      }
      {
        match._props.app-id = "^com.interversehq.qView$";
        open-floating = true;
      }
      {
        match._children = [
          {_props.app-id = "^mpv$";}
          {_props.app-id = "^.+exe$";}
          {_props.app-id = "^celluloid$";}
          {
            _props.app-id = "^zen-beta$";
            _props.title = ".*YouTube.*";
          }
          {_props.title = ".*Bitwarden Password Manager.*";}
        ];
        block-out-from = "screencast";
      }

      {
        match._children = [
          {_props.app-id = "^zen-beta$";}
          {_props.app-id = "^com.mitchellh.ghostty$";}
          {_props.app-id = "^mpv$";}
          {_props.app-id = "^cafe.avery.Delfin$";}
          {_props.app-id = "^spotify$";}
          {_props.app-id = "^com.jeffser.Nocturne$";}
          {_props.app-id = "^vesktop$";}
        ];
        open-maximized = true;
        open-maximized-to-edges = true;
      }

      # Picture-in-Picture
      {
        match._props.title = "^Picture-in-Picture$";
        open-floating = true;
        open-on-workspace = "special:overlay";
      }

      # File chooser dialogs
      {
        match._children = [
          {_props.app-id = "^org.gnome.FileRoller$";}
          {_props.app-id = "^file_progress$";}
          {_props.app-id = "^confirm$";}
          {_props.app-id = "^dialog$";}
          {_props.app-id = "^download$";}
          {_props.app-id = "^notification$";}
          {_props.app-id = "^error$";}
          {_props.app-id = "^confirmreset$";}
          {_props.title = ".*Open File.*";}
          {_props.title = ".*File Upload.*";}
          {_props.title = "^branchdialog$";}
          {_props.title = "^Confirm to replace files$";}
          {_props.title = "^File Operation Progress$";}
        ];
        open-floating = true;
      }

      # Screen sharing indicators - move to special workspace
      {
        match._children = [
          {_props.title = "^Firefox — Sharing Indicator$";}
          {_props.title = "^Zen — Sharing Indicator$";}
          {_props.title = ".*is sharing (your screen|a window)\\.";}
        ];
        open-on-workspace = "special:screencast";
      }

      # xwaylandvideobridge - hide completely
      {
        match._props.app-id = "^xwaylandvideobridge$";
        open-floating = true;
        default-column-width.fixed = 1;
        default-window-height.fixed = 1;
      }
    ];
  };
}
