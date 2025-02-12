{...}: let
  shellAliases = {
    pdf = "tdf";
    space = "ncdu";
    icat = "wezterm imgcat";
    wssh = "wezterm ssh";
  };
in {
  programs = {
    zsh.shellAliases = shellAliases;
    nushell.shellAliases = shellAliases;
  };
}
