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

      niri = {
        enableKeybinds = false;
        enableSpawn = false;

        includes = {
          enable = true;

          override = true;
          originalFileName = "hm";
          filesToInclude = [
            "alttab"
            "colors"
            "cursor"
            "layout"
            "outputs"
            "windowrules"
            "wpblur"
          ];
        };
      };

      # package = pkgs.unstable.dms-shell;
      quickshell.package = pkgs.unstable.quickshell;
      dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableVPN = true;

      systemd.enable = false;
    };
  };
}
