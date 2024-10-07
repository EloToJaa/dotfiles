
{ pkgs, ... }:
{
  programs.lazygit = {
    enable = true;

    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "lavender";
    };
  };
}
