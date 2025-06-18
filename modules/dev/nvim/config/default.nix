let
  dir = "nvim/lua/elotoja/core/";
in {
  xdg.configFile."${dir}init.lua".source = ./init.lua;
  xdg.configFile."${dir}keymaps.lua".source = ./keymaps.lua;
  xdg.configFile."${dir}options.lua".source = ./options.lua;
  xdg.configFile."${dir}palette.lua".source = ./palette.lua;
}
