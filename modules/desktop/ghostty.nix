{
  pkgs,
  inputs,
  ...
}: let
  ghostty = inputs.ghostty.packages.${pkgs.system}.default;
in {
  home.packages = [ghostty];

  xdg.configFile."ghostty/config".text = ''
    # Font
    font-family = "Maple Mono"
    font-size = 14
    font-thicken = true
    font-feature = ss01
    font-feature = ss04

    bold-is-bright = false
    adjust-box-thickness = 1

    # Theme
    theme = "catppuccin"
    background-opacity = 0.66

    cursor-style = bar
    cursor-style-blink = false
    adjust-cursor-thickness = 1

    resize-overlay = never
    copy-on-select = false
    confirm-close-surface = false
    mouse-hide-while-typing = true

    window-theme = ghostty
    window-padding-x = 4
    window-padding-y = 6
    window-padding-balance = true
    window-padding-color = background
    window-inherit-working-directory = true
    window-inherit-font-size = true
    window-decoration = false

    gtk-titlebar = false
    gtk-single-instance = false
    gtk-tabs-location = bottom
    gtk-wide-tabs = false

    auto-update = off
    term = ghostty
    clipboard-paste-protection = false

    keybind = shift+end=unbind
    keybind = shift+home=unbind
    keybind = ctrl+shift+left=unbind
    keybind = ctrl+shift+right=unbind
    keybind = shift+enter=text:\n
  '';

  xdg.configFile."ghostty/themes/catppuccin".text = ''
    palette = 0=#45475a
    palette = 1=#f38ba8
    palette = 2=#a6e3a1
    palette = 3=#f9e2af
    palette = 4=#89b4fa
    palette = 5=#f5c2e7
    palette = 6=#94e2d5
    palette = 7=#bac2de
    palette = 8=#585b70
    palette = 9=#f38ba8
    palette = 10=#a6e3a1
    palette = 11=#f9e2af
    palette = 12=#89b4fa
    palette = 13=#f5c2e7
    palette = 14=#94e2d5
    palette = 15=#a6adc8
    background = 1e1e2e
    foreground = cdd6f4
    cursor-color = f5e0dc
    selection-background = 353749
    selection-foreground = cdd6f4
  '';
}
