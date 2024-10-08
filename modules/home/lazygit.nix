
{ pkgs, variables, ... }:
{
  programs.lazygit = {
    enable = true;

    catppuccin = {
      enable = true;
      flavor = "${variables.catppuccin.flavor}";
      accent = "${variables.catppuccin.accent}";
    };
  };
}
