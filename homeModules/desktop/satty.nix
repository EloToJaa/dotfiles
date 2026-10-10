{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.satty;
in {
  options.modules.desktop.satty = {
    enable = lib.mkEnableOption "Enable satty";
  };
  config = lib.mkIf cfg.enable {
    programs.satty = {
      enable = true;
      package = pkgs.unstable.satty;
      settings = {
        general = {
          fullscreen = true;
          # Only exit after the file save; `true` means "exit on copy too",
          # which cut the Enter action list short before save-to-file ran.
          early-exit = ["save"];
          corner-roundness = 12;
          initial-tool = "brush";
          copy-command = "wl-copy";
          annotation-size-factor = 2;
          # Negative because satty multiplies the raw scroll delta by this and
          # only inverts it for touchpads, so a mouse wheel pans backwards.
          pan-step-size = -50;
          output-filename = "${config.home.homeDirectory}/Pictures/Screenshots/satty-%Y-%m-%d_%H-%M-%S.png";
          save-after-copy = false;
          default-hide-toolbars = false;
          # focus-toggles-toolbars = false;
          # default-fill-shapes = false;
          primary-highlighter = "block";
          disable-notifications = false;
          actions-on-right-click = [];
          # Keep the edited image in both places, like a plain dms capture.
          actions-on-enter = ["save-to-clipboard" "save-to-file"];
          actions-on-escape = ["exit"];
          no-window-decoration = true;
          brush-smooth-history-size = 10;
        };

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
    };
  };
}
