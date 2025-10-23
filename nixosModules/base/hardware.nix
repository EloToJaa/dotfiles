{
  config,
  lib,
  ...
}: let
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
    hardware.enableRedistributableFirmware = true;
    services.fstrim.enable = true;
  };
}
