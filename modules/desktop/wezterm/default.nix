{
  inputs,
  pkgs,
  host,
  ...
}: let
  shellAliases = {
    wicat = "wezterm imgcat";
    wssh = "wezterm ssh";
  };
in {
  # home.packages = [inputs.wezterm.packages.${pkgs.system}.default];
  programs = {
    wezterm = {
      enable = true;
      package = inputs.wezterm.packages.${pkgs.system}.default;
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
}
