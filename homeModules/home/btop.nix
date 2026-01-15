{
  pkgs,
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) catppuccin;
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
        vim_keys = true;
      };
    };
    catppuccin.btop = {
      enable = true;
      inherit (catppuccin) flavor;
    };

    home.packages = with pkgs.unstable; [nvtopPackages.amd];
  };
}
