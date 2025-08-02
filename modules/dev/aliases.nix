let
  shellAliases = {
    pdf = "tdf";
    space = "ncdu";
  };
in {
  programs = {
    zsh.shellAliases = shellAliases;
  };
}
