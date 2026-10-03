{
  lib,
  config,
  ...
}: let
  cfg = config.modules.shared.cpu;
in {
  config = lib.mkIf (cfg.vendor == "amd") {
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
