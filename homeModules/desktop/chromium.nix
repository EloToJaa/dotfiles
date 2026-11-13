{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.chromium;
in {
  options.modules.desktop.chromium = {
    enable = lib.mkEnableOption "Enable chromium";
  };
  config = lib.mkIf cfg.enable {
    programs.chromium.enable = true;
  };
}
