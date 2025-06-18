{pkgs, ...}: {
  home.packages = with pkgs.vimPlugins; [
    lz-n
  ];
  xdg.configFile."nvim/lua/elotoja/lazy.lua".source = ./lazy.lua;
}
