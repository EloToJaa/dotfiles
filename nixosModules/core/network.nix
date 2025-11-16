{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.network;
in {
  options.modules.core.network = {
    enable = lib.mkEnableOption "Enable network managment";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs.unstable; [
      networkmanagerapplet
      iwmenu
    ];
  };
}
