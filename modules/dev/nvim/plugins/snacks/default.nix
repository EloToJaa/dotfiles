{pkgs, ...}: {
  home.packages = with pkgs.vimPlugins; [
    snacks-nvim
  ];
  xdg.configFile."nvim/lua/elotoja/plugins/snacks.lua".source = ./snacks.lua;
}
