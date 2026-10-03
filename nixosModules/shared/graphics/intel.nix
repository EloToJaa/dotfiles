{
  lib,
  config,
  ...
}: let
  cfg = config.modules.shared.graphics;
in {
  config = lib.mkIf (cfg.enable && cfg.vendor == "intel") {
    services.xserver.videoDrivers = ["modesetting"];
    boot.initrd.kernelModules = lib.mkIf cfg.earlyBoot ["i915"];
  };
}
