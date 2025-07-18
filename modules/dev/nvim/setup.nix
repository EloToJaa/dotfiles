let
  shellAliases = {
    vim = "nvim";
    vi = "nvim";
    v = "nvim";
  };
in {
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
  };

  programs = {
    zsh.shellAliases = shellAliases;
    nushell.shellAliases = shellAliases;
  };
}
