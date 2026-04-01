{
  inputs,
  config,
  lib,
  settings,
  pkgs,
  ...
}: let
  inherit (settings) isLaptop;
  cfg = config.modules.desktop.vicinae;
in {
  options.modules.desktop.vicinae = {
    enable = lib.mkEnableOption "Enable vicinae";
  };
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];
  config = lib.mkIf cfg.enable {
    services.vicinae = {
      enable = true;

      systemd = {
        enable = true;
        autoStart = true;
        environment = {
          USE_LAYER_SHELL = "1";
          QT_SCALE_FACTOR =
            if isLaptop
            then "1.2"
            else "1.1";
        };
      };

      settings = {
        close_on_focus_loss = true;
        consider_preedit = true;
        pop_to_root_on_close = true;
        favicon_service = "twenty";
        search_files_in_root = true;
        font.normal = {
          size = 11;
          family = "JetBrainsMono Nerd Font";
        };
        theme = {
          light = {
            name = "catppuccin-latte";
            icon_theme = "Papirus-Light";
          };
          dark = {
            name = "catppuccin-mocha";
            icon_theme = "Papirus-Dark";
          };
        };

        telemetry.system_info = false;
        launcher_window = {
          opacity = 0.9;
          client_side_decorations = {
            enabled = true;
            rounding = 10;
            border_width = 1;
          };
          blur.enabled = true;
        };
        favorites = [
          "clipboard:history"
        ];
        fallbacks = [
          "files:search"
        ];
        providers = {
          clipboard.preferences.monitoring = true;
          "@Gelei/bluetooth-0".preferences = {
            connectionToggleable = true;
          };
        };
      };
      extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
        bluetooth
        nix
        power-profile
        niri
        ssh
        it-tools
        # systemd
        wifi-commander
      ];
    };
  };
}
