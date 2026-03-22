{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    # Use default/auto-detected output configuration
    # Niri will auto-configure monitors with preferred resolution and auto positioning
    # Similar to hyprland's: monitor = [",preferred,auto,auto"];

    # If you need specific monitor configurations, add them here:
    # programs.niri.settings.outputs = {
    #   "HDMI-A-1" = {
    #     scale = 1.0;
    #     position = { x = 0; y = 0; };
    #   };
    #   "DP-2" = {
    #     scale = 1.0;
    #     position = { x = 1920; y = 0; };
    #   };
    # };

    # Install nwg-displays for monitor management (same as hyprland)
    home.packages = with pkgs.unstable; [nwg-displays];
  };
}
