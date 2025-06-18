{pkgs, ...}: {
  home.packages = with pkgs.vimPlugins; [
    snacks-nvim
    mini-icons
    nvim-web-devicons
  ];
  xdg.configFile."nvim/lua/elotoja/plugins/snacks.lua".source = ./snacks.lua;
}
