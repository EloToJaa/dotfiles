{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.bluetooth;
in {
  options.modules.desktop.bluetooth = {
    enable = lib.mkEnableOption "Enable bluetooth";
  };
  config = lib.mkIf cfg.enable {
    services.mpris-proxy.enable = true;
  };
}
