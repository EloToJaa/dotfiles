{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.home.btop;
in {
  options.modules.home.btop = {
    enable = lib.mkEnableOption "Enable btop";
  };
  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      package = pkgs.unstable.btop;

      settings = {
        theme_background = false;
        update_ms = 500;
        rounded_corners = false;
      };
    };
    catppuccin.btop = {
      enable = true;
      inherit (config.modules.settings.catppuccin) flavor;
    };

    home.packages = with pkgs.unstable; [nvtopPackages.amd];
  };
}
