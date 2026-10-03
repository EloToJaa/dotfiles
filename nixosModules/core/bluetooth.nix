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
  config = lib.mkIf (config.modules.core.enable && cfg.enable) {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = false;

    environment.systemPackages = with pkgs; [
      bluez
      # unstable.bzmenu
    ];
  };
}
