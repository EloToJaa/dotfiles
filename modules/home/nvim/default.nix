{ pkgs, ... }:
{
  home.packages = (with pkgs; [ neovim ]);

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  programs.zsh.shellAliases = {
    vim = "nvim";
    vi = "nvim";
  };
}
