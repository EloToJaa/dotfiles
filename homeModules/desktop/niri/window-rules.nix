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
        _children = map (matcher: {match._props = matcher;}) [
          {app-id = "^org.gnome.Nautilus$";}
          {app-id = "^org.gnome.TextEditor$";}
          {app-id = "^org.gnome.Papers$";}
          {app-id = "^.virt-manager-wrapped$";}
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
        _children = map (matcher: {match._props = matcher;}) [
          {app-id = "^mpv$";}
          {app-id = "^.+exe$";}
          {app-id = "^celluloid$";}
          {
            app-id = "^zen-beta$";
            title = ".*YouTube.*";
          }
          {title = ".*Bitwarden Password Manager.*";}
        ];
        block-out-from = "screencast";
      }

      # {
      #   _children = map (matcher: {match._props = matcher;}) [
      #     {app-id = "^zen-beta$";}
      #     {app-id = "^com.mitchellh.ghostty$";}
      #     {app-id = "^mpv$";}
      #     {app-id = "^cafe.avery.Delfin$";}
      #     {app-id = "^spotify$";}
      #     {app-id = "^com.jeffser.Nocturne$";}
      #     {app-id = "^vesktop$";}
      #   ];
      #   open-maximized = true;
      #   open-maximized-to-edges = true;
      # }

      # Picture-in-Picture
      {
        match._props.title = "^Picture-in-Picture$";
        open-floating = true;
        open-on-workspace = "special:overlay";
      }

      # File chooser dialogs
      {
        _children = map (matcher: {match._props = matcher;}) [
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
        ];
        open-floating = true;
      }

      # Screen sharing indicators - move to special workspace
      {
        _children = map (matcher: {match._props = matcher;}) [
          {title = "^Firefox — Sharing Indicator$";}
          {title = "^Zen — Sharing Indicator$";}
          {title = ".*is sharing (your screen|a window)\\.";}
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
