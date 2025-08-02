{
  programs.ghostty = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    installBatSyntax = true;
    installVimSyntax = true;

    settings = {
      font-family = [
        "JetBrainsMono Nerd Font"
        "Maple Mono"
        "DejaVu Sans"
      ];
      font-size = 12.4;
      font-feature = [
        "calt"
        "ss03"
      ];

      bold-is-bright = true;
      selection-invert-fg-bg = true;

      theme = "catppuccin-mocha";
      background-opacity = 0.9;
      background-blur = 10;

      cursor-style = "bar";
      cursor-style-blink = false;
      adjust-cursor-thickness = 1;

      resize-overlay = "never";
      copy-on-select = false;
      confirm-close-surface = false;
      mouse-hide-while-typing = true;

      window-theme = "ghostty";
      window-padding-x = 4;
      window-padding-y = 0;
      window-padding-balance = true;
      window-padding-color = "background";
      window-inherit-working-directory = true;
      window-inherit-font-size = true;
      window-decoration = false;

      gtk-titlebar = false;
      gtk-single-instance = false;
      gtk-tabs-location = "bottom";
      gtk-wide-tabs = false;

      auto-update = "off";
      term = "ghostty";
      clipboard-paste-protection = false;

      keybind = [
        "shift+end=unbind"
        "shift+home=unbind"
        "ctrl+shift+left=unbind"
        "ctrl+shift+right=unbind"
        "ctrl+tab=unbind"
        "shift+enter=text:\n"
      ];
    };
  };
}
