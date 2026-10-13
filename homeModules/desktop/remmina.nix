{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop.remmina;
in {
  options.modules.desktop.remmina = {
    enable = lib.mkEnableOption "Enable remmina module";
  };
  config = lib.mkIf cfg.enable {
    services.remmina = {
      enable = true;
      package = pkgs.unstable.remmina;
      addRdpMimeTypeAssoc = true;
      systemdService.enable = false; # don't keep a tray instance running in the background
    };
  };
}
