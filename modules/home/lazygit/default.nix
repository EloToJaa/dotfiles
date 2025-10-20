{
  pkgs,
  lib,
  config,
  ...
}: let
  shellAliases = {
    lg = "lazygit";
  };
  cfg = config.modules.home.lazygit;
in {
  options.modules.home.lazygit = {
    enable = lib.mkEnableOption "Enable lazygit";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      lazygit
      difftastic
    ];

    # https://github.com/catppuccin/lazygit/blob/main/themes/mocha/blue.yml
    xdg.configFile = {
      "lazygit/config.yml".source = ./config.yml;
    };

    programs = {
      zsh.shellAliases = shellAliases;
    };
  };
}
