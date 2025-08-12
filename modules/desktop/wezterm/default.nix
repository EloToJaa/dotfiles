{
  inputs,
  pkgs,
  host,
  ...
}: let
  shellAliases = {
    icat = "wezterm imgcat";
    wssh = "wezterm ssh";
  };
in {
  home.packages = [inputs.wezterm.packages.${pkgs.system}.default];

  programs = {
    zsh.shellAliases = shellAliases;
  };

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
