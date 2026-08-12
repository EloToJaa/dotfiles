{
  pkgs,
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) username;
  cfg = config.modules.desktop.prismlauncher;
in {
  options.modules.desktop.prismlauncher = {
    enable = lib.mkEnableOption "Enable prismlauncher";
  };
  config = lib.mkIf cfg.enable {
    programs.prismlauncher = {
      enable = true;
      package = pkgs.unstable.prismlauncher;
      settings = {
        ConsoleMaxLines = 100000;
        ShowConsole = true;
      };
    };
  };
}
