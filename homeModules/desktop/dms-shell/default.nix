{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.dms-shell;
in {
  options.modules.desktop.dms-shell = {
    enable = lib.mkEnableOption "Enable DankMaterialShell";
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile."DankMaterialShell/settings.json".source = ./settings.json;
    xdg.configFile."DankMaterialShell/clsettings.json".text = builtins.toJSON {
      autoClearDays = 1;
      clearAtStartup = true;
      disabled = false;
      maxEntrySize = 10485760;
      maxHistory = 25;
      maxPinned = 25;
    };
    xdg.configFile."DankMaterialShell/plugin_settings.json".text = builtins.toJSON {
      dankKDEConnect = {
        enabled = true;
        selectedDeviceId = "";
      };
      dankLauncherKeys.enabled = true;
    };
    programs.dank-calendar = {
      enable = true;
      quickshell.package = pkgs.unstable.quickshell;
      systemd.enable = true;
    };
    wayland.windowManager.niri.settings._children = map (path: {include._args = [path];}) [
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
