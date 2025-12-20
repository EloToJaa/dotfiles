{
  inputs,
  pkgs,
  host,
  config,
  lib,
  ...
}: let
  shellAliases = {
    wicat = "wezterm imgcat";
    wssh = "wezterm ssh";
  };
  cfg = config.modules.desktop.wezterm;
in {
  options.modules.desktop.wezterm = {
    enable = lib.mkEnableOption "Enable wezterm";
  };
  config = lib.mkIf cfg.enable {
    programs = {
      wezterm = {
        enable = true;
        package = inputs.wezterm.packages.${pkgs.stdenv.hostPlatform.system}.default;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
      zsh.shellAliases = shellAliases;
    };
    catppuccin.wezterm.enable = false;

    xdg.configFile."wezterm" = {
      recursive = true;
      source = ./wezterm;
    };

    xdg.configFile."wezterm/utils/variables.lua".text = ''
      local M = {}
      M.host = "${host}"
      return M
    '';
  };
}
