{pkgs, ...}: let
  shellAliases = {
    lg = "lazygit";
  };
in {
  home.packages = with pkgs; [
    lazygit
    difftastic
  ];

  # https://github.com/catppuccin/lazygit/blob/main/themes/mocha/blue.yml
  xdg.configFile = {
    "lazygit/config.yml".source = ./config.yml;
  };

  programs = {
    zsh.shellAliases = shellAliases;
    nushell.shellAliases = shellAliases;
  };
}
