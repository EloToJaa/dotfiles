{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.helium;
in {
  options.modules.desktop.helium = {
    enable = lib.mkEnableOption "Enable helium";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.helium];
  };
}
