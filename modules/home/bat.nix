{
  pkgs,
  config,
  lib,
  ...
}: let
  shellAliases = {
    cat = "bat";
    less = "bat";
  };
  cfg = config.modules.home.bat;
in {
  options.modules.home.bat = {
    enable = lib.mkEnableOption "Enable bat";
  };
  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      package = pkgs.unstable.bat;

      config = {
        pager = "less -FR";
      };

      extraPackages = with pkgs.unstable.bat-extras; [
        # batman
        batpipe
        batgrep
        # batdiff
      ];
    };
    programs = {
      zsh.shellAliases = shellAliases;
    };
    catppuccin.bat = {
      enable = true;
      inherit (config.modules.settings.catppuccin) flavor;
    };
  };
}
