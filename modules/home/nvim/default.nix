{ pkgs, ... }:
{
  home.packages = (with pkgs; [ neovim ]);

  xdg.configFile."nvim".source = ./nvim;

  programs.zsh.shellAliases = {
    vim = "nvim";
    vi = "nvim";
  };
}
