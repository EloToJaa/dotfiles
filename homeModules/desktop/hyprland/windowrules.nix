{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) discord;
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      windowrule = [
        "match:class ^(audacious)$, float on"
        "match:class ^(waypaper)$, pin on"

        "match:class ^(org.pulseaudio.pavucontrol)$, float on"
        "match:class ^(org.pulseaudio.pavucontrol)$, size 1200 725"
        "match:class ^(org.pulseaudio.pavucontrol)$, center on"

        "match:class ^(com.interversehq.qView)$, float on"
        "match:class ^(com.interversehq.qView)$, center on"
        "match:class ^(com.interversehq.qView)$, size 1200 725"

        "match:class ^(nwg-displays)$, float on"
        "match:class ^(nwg-displays)$, size 1200 725"
        "match:class ^(nwg-displays)$, center on"

        "match:class ^(mpv)$, float on"
        "match:class ^(mpv)$, center on"
        "match:class ^(mpv)$, size 1200 725"
        "match:class ^(mpv|.+exe|celluloid)$, idle_inhibit focus"
        "match:class ^(zen)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"
        "match:class ^(zen)$, idle_inhibit fullscreen"

        # No gaps when only
        "match:workspace w[t1], match:float false, border_size 0"
        "match:workspace w[t1], match:float false, rounding 0"
        "match:workspace w[t1], match:float false, border_size 0"
        "match:workspace w[t1], match:float false, rounding 0"
        "match:workspace f[1], match:float false, border_size 0"
        "match:workspace f[1], match:float false, rounding 0"

        "match:title ^(Picture-in-Picture)$, float on"
        "match:title ^(Picture-in-Picture)$, opacity 1.0 override"
        "match:title ^(Picture-in-Picture)$, pin on"
        "match:title ^(.*mpv.*)$, opacity 1.0 override"
        "match:class (evince), opacity 1.0 override"

        "match:class ^(mpv)$, idle_inhibit focus"
        "match:class ^(firefox)$, idle_inhibit fullscreen on"
        "match:class ^(org.gnome.FileRoller)$, float on"
        "match:class ^(org.pulseaudio.pavucontrol)$, float on"
        "match:class ^(.sameboy-wrapped)$, float on"
        "match:class ^(file_progress)$, float on"
        "match:class ^(confirm)$, float on"
        "match:class ^(dialog)$, float on"
        "match:class ^(download)$, float on"
        "match:class ^(notification)$, float on"
        "match:class ^(error)$, float on"
        "match:class ^(confirmreset)$, float on"
        "match:title ^(.*Open File.*)$, float on"
        "match:title ^(.*File Upload.*)$, float on"
        "match:title ^(branchdialog)$, float on"
        "match:title ^(Confirm to replace files)$, float on"
        "match:title ^(File Operation Progress)$, float on"
        "match:title ^(.*Bitwarden Password Manager.*)$, float on"

        "match:title ^(Firefox — Sharing Indicator)$, workspace special silent"
        "match:title ^(Zen — Sharing Indicator)$, workspace special silent"
        "match:title ^(.*is sharing (your screen|a window)\.)$, workspace special silent"

        "match:class ^(xwaylandvideobridge)$, opacity 0.0 override"
        "match:class ^(xwaylandvideobridge)$, no_anim on"
        "match:class ^(xwaylandvideobridge)$, no_initial_focus on"
        "match:class ^(xwaylandvideobridge)$, max_size 1 1"
        "match:class ^(xwaylandvideobridge)$, no_blur on"

        "match:class ^(zen-beta)$, workspace 1"
        "match:class ^(evince)$, workspace 4"
        "match:class ^(gimp)$, workspace 4"
        "match:class ^(Audacious)$, workspace 5"
        "match:class ^(${discord})$, workspace 5"
        "match:class ^(Spotify)$, workspace 6"
        "match:class ^(com.obsproject.Studio)$, workspace 8"

        "match:float true, border_size 0"

        # Remove context menu transparancy in chromium based apps
        "match:class ^()$, match:title ^()$, opaque on"
        "match:class ^()$, match:title ^()$, no_shadow on"
        "match:class ^()$, match:title ^()$, no_blur on"
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
