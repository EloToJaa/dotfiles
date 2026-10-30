{
  lib,
  config,
  pkgs,
  inputs,
  settings,
  ...
}: let
  inherit (settings) catppuccin;
  cfg = config.modules.desktop.dms-shell;
  dmsPackage = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.dms-shell;
in {
  options.modules.desktop.dms-shell = {
    enable = lib.mkEnableOption "Enable DankMaterialShell";
  };
  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;

      package = dmsPackage;
      quickshell.package = pkgs.unstable.quickshell;
      # dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableVPN = true;

      systemd.enable = true;

      settings =
        import ./settings.nix
        // {
          # Load the registry theme from the store instead of a UI-installed copy
          currentThemeName = "custom";
          currentThemeCategory = "registry";
          customThemeFile = "${inputs.dms-plugin-registry}/themes/catppuccin/theme.json";
          registryThemeVariants.catppuccin = {
            dark = {inherit (catppuccin) flavor accent;};
            light = {
              flavor = "latte";
              inherit (catppuccin) accent;
            };
          };
        };

      clipboardSettings = {
        autoClearDays = 1;
        clearAtStartup = true;
        disabled = false;
        maxEntrySize = 10485760;
        maxHistory = 25;
        maxPinned = 25;
      };

      plugins = {
        aiOverviewControl.enable = true;
        dankKDEConnect = {
          enable = true;
          settings.selectedDeviceId = "";
        };
        dankLauncherKeys = {
          enable = true;
          settings = {};
        };
      };
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
