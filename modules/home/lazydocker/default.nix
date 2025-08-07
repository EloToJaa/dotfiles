{pkgs, ...}: let
  shellAliases = {
    ld = "lazydocker";
  };
in {
  home.packages = with pkgs.unstable; [lazydocker];

  xdg.configFile = {
    "lazydocker/config.yml".source = ./config.yml;
  };

  programs = {
    zsh.shellAliases = shellAliases;
  };
}
