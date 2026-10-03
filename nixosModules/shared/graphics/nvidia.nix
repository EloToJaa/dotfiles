{
  lib,
  config,
  ...
}: let
  cfg = config.modules.shared.graphics;
in {
  config = lib.mkIf (cfg.enable && cfg.vendor == "nvidia") {
    services.xserver.videoDrivers = ["nvidia"];
    boot.initrd.kernelModules = lib.mkIf cfg.earlyBoot ["nvidia" "nvidia_modeset" "nvidia_drm"];
    hardware.nvidia = {
      modesetting.enable = lib.mkDefault true;
      open = lib.mkDefault cfg.nvidia.open;
    };
  };
}
