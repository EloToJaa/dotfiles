{
  lib,
  config,
  ...
}: let
  cfg = config.modules.shared.graphics;
in {
  config = lib.mkIf (cfg.enable && cfg.vendor == "amd") {
    services.xserver.videoDrivers = ["amdgpu"];
    boot.initrd.kernelModules = lib.mkIf cfg.earlyBoot ["amdgpu"];
  };
}
