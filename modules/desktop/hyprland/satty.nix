{pkgs, ...}: {
  programs.satty = {
    enable = true;
    package = pkgs.unstable.satty;
    settings = {
      fullscreen = true;
      early-exit = true;
      corner-roundness = 12;
      initial-tool = "brush";
      copy-command = "wl-copy";
      annotation-size-factor = 2;
      output-filename = "/tmp/test-%Y-%m-%d_%H:%M:%S.png";
      save-after-copy = false;
      default-hide-toolbars = false;
      focus-toggles-toolbars = false;
      default-fill-shapes = false;
      primary-highlighter = "block";
      disable-notifications = false;
      actions-on-right-click = [];
      actions-on-enter = ["save-to-clipboard"];
      actions-on-escape = ["exit"];
      action-on-enter = "save-to-clipboard";
      right-click-copy = false;
      no-window-decoration = true;
      brush-smooth-history-size = 10;

      font = {
        family = "CaskaydiaCove Nerd Font";
        style = "Bold";
      };

      color-palette = {
        palette = [
          "#00ffff"
          "#a52a2a"
          "#dc143c"
          "#ff1493"
          "#ffd700"
          "#008000"
        ];
      };

      custom = [
        "#00ffff"
        "#a52a2a"
        "#dc143c"
        "#ff1493"
        "#ffd700"
        "#008000"
      ];
    };
  };
}
