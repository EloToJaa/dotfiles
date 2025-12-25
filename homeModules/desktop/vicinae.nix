{
  inputs,
  config,
  lib,
  ...
}: let
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
      useLayerShell = true;

      systemd = {
        enable = true;
        autoStart = true;
        environment = {
          USE_LAYER_SHELL = 1;
        };
      };

      settings = {
        faviconService = "twenty";
        font = {
          normal = "CaskaydiaCove Nerd Font";
          size = 12;
        };
        popToRootOnClose = true;
        rootSearch = {
          searchFiles = true;
        };
        theme = {
          name = "catppuccin-mocha.json";
          iconTheme = "Papirus-Dark";
        };
        window = {
          csd = true;
          opacity = 1;
          rounding = 10;
        };
      };
    };
  };
}
