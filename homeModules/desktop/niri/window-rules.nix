{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.niri.settings.window-rule = [
      {
        geometry-corner-radius = 8.0;
        clip-to-geometry = true;
        tiled-state = true;
        draw-border-with-background = false;
      }
      {
        match._props.app-id._raw = ''r#"^winboat$"#'';
        # clip-to-geometry = false;
        # tiled-state = false;
        # border.enable = false;
        # focus-ring.enable = false;
      }
      {
        match._props.app-id._raw = ''r#"^winboat-.*"#'';
        clip-to-geometry = false;
        tiled-state = false;
        open-floating = true;
        # border.enable = false;
        # focus-ring.enable = false;
      }
      {
        match = [
          {_props.app-id._raw = ''r#"^org.gnome.Nautilus$"#'';}
          {_props.app-id._raw = ''r#"^org.gnome.TextEditor$"#'';}
          {_props.app-id._raw = ''r#"^org.gnome.Papers$"#'';}
          {_props.app-id._raw = ''r#"^.virt-manager-wrapped$"#'';}
        ];
        default-column-width.proportion = 0.5;
      }

      # Floating applications
      {
        match._props = {
          app-id._raw = ''r#"^audacious$"#'';
          title._raw = ''r#".*Bitwarden Password Manager.*"#'';
        };
        default-column-width.proportion = 0.5;
        open-floating = true;
      }
      {
        match._props.app-id._raw = ''r#"^org.pulseaudio.pavucontrol$"#'';
        default-column-width.fixed = 1200;
        open-floating = true;
      }
      {
        match._props.app-id._raw = ''r#"^com.interversehq.qView$"#'';
        open-floating = true;
      }
      {
        match = [
          {_props.app-id._raw = ''r#"^mpv$"#'';}
          {_props.app-id._raw = ''r#"^.+exe$"#'';}
          {_props.app-id._raw = ''r#"^celluloid$"#'';}
          {
            _props.app-id._raw = ''r#"^zen-beta$"#'';
            _props.title._raw = ''r#".*YouTube.*"#'';
          }
          {_props.title._raw = ''r#".*Bitwarden Password Manager.*"#'';}
        ];
        block-out-from = "screencast";
      }

      {
        match = [
          {_props.app-id._raw = ''r#"^zen-beta$"#'';}
          {_props.app-id._raw = ''r#"^com.mitchellh.ghostty$"#'';}
          {_props.app-id._raw = ''r#"^mpv$"#'';}
          {_props.app-id._raw = ''r#"^cafe.avery.Delfin$"#'';}
          {_props.app-id._raw = ''r#"^spotify$"#'';}
          {_props.app-id._raw = ''r#"^vesktop$"#'';}
        ];
        open-maximized-to-edges = true;
      }

      # Picture-in-Picture
      {
        match._props.title._raw = ''r#"^Picture-in-Picture$"#'';
        open-floating = true;
        open-on-workspace = "special:overlay";
      }

      # File chooser dialogs
      {
        match = [
          {_props.app-id._raw = ''r#"^org.gnome.FileRoller$"#'';}
          {_props.app-id._raw = ''r#"^file_progress$"#'';}
          {_props.app-id._raw = ''r#"^confirm$"#'';}
          {_props.app-id._raw = ''r#"^dialog$"#'';}
          {_props.app-id._raw = ''r#"^download$"#'';}
          {_props.app-id._raw = ''r#"^notification$"#'';}
          {_props.app-id._raw = ''r#"^error$"#'';}
          {_props.app-id._raw = ''r#"^confirmreset$"#'';}
          {_props.title._raw = ''r#".*Open File.*"#'';}
          {_props.title._raw = ''r#".*File Upload.*"#'';}
          {_props.title._raw = ''r#"^branchdialog$"#'';}
          {_props.title._raw = ''r#"^Confirm to replace files$"#'';}
          {_props.title._raw = ''r#"^File Operation Progress$"#'';}
        ];
        open-floating = true;
      }

      # Screen sharing indicators - move to special workspace
      {
        match = [
          {_props.title._raw = ''r#"^Firefox — Sharing Indicator$"#'';}
          {_props.title._raw = ''r#"^Zen — Sharing Indicator$"#'';}
          {_props.title._raw = ''r#".*is sharing (your screen|a window)\.$"#'';}
        ];
        open-on-workspace = "special:screencast";
      }

      # xwaylandvideobridge - hide completely
      {
        match._props.app-id._raw = ''r#"^xwaylandvideobridge$"#'';
        open-floating = true;
        default-column-width.fixed = 1;
        default-window-height.fixed = 1;
      }
    ];
  };
}
