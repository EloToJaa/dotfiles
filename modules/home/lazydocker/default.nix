{pkgs, ...}: let
  shellAliases = {
    ld = "lazydocker";
  };
in {
  home.packages = with pkgs; [lazydocker];

  xdg.configFile = {
    "lazydocker/config.yml".source = ./config.yml;
  };

  programs = {
    zsh.shellAliases = shellAliases;
    nushell.shellAliases = shellAliases;
  };
}
