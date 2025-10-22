{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.bluetooth;
in {
  options.modules.core.bluetooth = {
    enable = lib.mkEnableOption "Enable bluetooth module";
  };
  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;

    services.pulseaudio.configFile = pkgs.writeText "default.pa" ''
      load-module module-bluetooth-policy
      load-module module-bluetooth-discover
      ## module fails to load with
      ##   module-bluez5-device.c: Failed to get device path from module arguments
      ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
      # load-module module-bluez5-device
      # load-module module-bluez5-discover
    '';

    environment.systemPackages = with pkgs; [
      bluez
    ];
  };
}
