{
  config,
  lib,
  ...
}: let
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    hardware.enableRedistributableFirmware = true;
    services.fstrim.enable = true;
  };
}
