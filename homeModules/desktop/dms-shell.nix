{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.dms-shell;
in {
  options.modules.desktop.dms-shell = {
    enable = lib.mkEnableOption "Enable DankMaterialShell";
  };
  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;

      # package = pkgs.unstable.dms-shell;
      quickshell.package = pkgs.unstable.quickshell;
      dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableVPN = true;

      systemd.enable = true;
    };
    wayland.windowManager.niri.settings.include = map (path: {_args = [path];}) [
      "dms/alttab.kdl"
      "dms/colors.kdl"
      # "dms/cursor.kdl"
      # "dms/layout.kdl"
      "dms/outputs.kdl"
      "dms/windowrules.kdl"
      # "dms/wpblur.kdl"
    ];
  };
}
