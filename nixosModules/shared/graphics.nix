{
  lib,
  config,
  ...
}: let
  cfg = config.modules.shared.graphics;
in {
  options.modules.shared.graphics = {
    enable = lib.mkEnableOption "graphics support for workstations or GPU workloads";
    enable32Bit = lib.mkEnableOption "32-bit graphics support";
  };
  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      inherit (cfg) enable32Bit;
    };
  };
}
