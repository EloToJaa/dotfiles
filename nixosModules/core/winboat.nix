{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.winboat;
in {
  options.modules.core.winboat = {
    enable = lib.mkEnableOption "Enable winboat module";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs.unstable; [
      winboat
      freerdp
    ];
  };
}
