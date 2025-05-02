{
  inputs,
  pkgs,
  host,
  ...
}: {
  home.packages = [inputs.wezterm.packages.${pkgs.system}.default];

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
