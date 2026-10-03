{
  lib,
  config,
  ...
}: let
  cfg = config.modules.shared.cpu;
in {
  config = lib.mkIf (cfg.vendor == "intel") {
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
