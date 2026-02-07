{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab.mysql;
in {
  options.modules.homelab.mysql = {
    enable = lib.mkEnableOption "Enable mysql";
    port = lib.mkOption {
      type = lib.types.port;
      default = 1433;
    };
  };
  config = lib.mkIf cfg.enable {
    services.mysql = {
      enable = true;
      package = pkgs.unstable.mariadb;
      # settings.port = cfg.port;
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
