{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.printing;
in {
  options.modules.core.printing = {
    enable = lib.mkEnableOption "Enable printing";
  };
  config = lib.mkIf (config.modules.core.enable && cfg.enable) {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      printing = {
        enable = true;
        drivers = with pkgs; [
          cups-filters
          cups-browsed
        ];
      };
    };
  };
}
