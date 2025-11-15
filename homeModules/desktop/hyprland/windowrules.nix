{
  config,
  lib,
  ...
}: let
  inherit (config.settings) discord;
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      windowrule = [
        "float,class:^(com.interversehq.qView)$"
        "center,class:^(com.interversehq.qView)$"
        "size 1200 725,class:^(com.interversehq.qView)$"
        "float,class:^(mpv)$"
        "center,class:^(mpv)$"
        "size 1200 725,class:^(mpv)$"
        "float,class:^(audacious)$"
        "pin,class:^(waypaper)$"
        "idleinhibit focus,class:^(mpv)$"
        "float,class:^(org.pulseaudio.pavucontrol)$"
        "size 1200 725,class:^(org.pulseaudio.pavucontrol)$"
        "center,class:^(org.pulseaudio.pavucontrol)$"
        "float,class:^(nwg-displays)$"
        "size 1200 725,class:^(nwg-displays)$"
        "center,class:^(nwg-displays)$"

        # No gaps when only
        "bordersize 0, floating:0, onworkspace:w[t1]"
        "rounding 0, floating:0, onworkspace:w[t1]"
        "bordersize 0, floating:0, onworkspace:w[tg1]"
        "rounding 0, floating:0, onworkspace:w[tg1]"
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"

        "float, title:^(Picture-in-Picture)$"
        "opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "opacity 1.0 override 1.0 override, title:^(.*mpv.*)$"
        "opacity 1.0 override 1.0 override, class:(evince)"
        "workspace 1, class:^(zen-beta)$"
        "workspace 4, class:^(evince)$"
        "workspace 4, class:^(Gimp-2.10)$"
        "workspace 5, class:^(Audacious)$"
        "workspace 5, class:^(${discord})$"
        "workspace 6, class:^(Spotify)$"
        "workspace 8, class:^(com.obsproject.Studio)$"
        "idleinhibit focus, class:^(mpv)$"
        "idleinhibit fullscreen, class:^(firefox)$"
        "float,class:^(org.gnome.FileRoller)$"
        "float,class:^(org.pulseaudio.pavucontrol)$"
        "float,class:^(.sameboy-wrapped)$"
        "float,class:^(file_progress)$"
        "float,class:^(confirm)$"
        "float,class:^(dialog)$"
        "float,class:^(download)$"
        "float,class:^(notification)$"
        "float,class:^(error)$"
        "float,class:^(confirmreset)$"
        "float,title:^(Open File)$"
        "float,title:^(File Upload)$"
        "float,title:^(branchdialog)$"
        "float,title:^(Confirm to replace files)$"
        "float,title:^(File Operation Progress)$"

        "opacity 0.0 override,class:^(xwaylandvideobridge)$"
        "noanim,class:^(xwaylandvideobridge)$"
        "noinitialfocus,class:^(xwaylandvideobridge)$"
        "maxsize 1 1,class:^(xwaylandvideobridge)$"
        "noblur,class:^(xwaylandvideobridge)$"

        # "maxsize 1111 700, floating: 1"
        # "center, floating: 1"

        # Remove context menu transparancy in chromium based apps
        "opaque,class:^()$,title:^()$"
        "noshadow,class:^()$,title:^()$"
        "noblur,class:^()$,title:^()$"
      ];
      # No gaps when only
      workspace = [
        "w[t1], gapsout:0, gapsin:0"
        "w[tg1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];
    };
  };
}
