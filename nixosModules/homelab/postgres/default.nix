{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab.postgres;
in {
  options.modules.homelab.postgres = {
    enable = lib.mkEnableOption "Enable postgres";
    name = lib.mkOption {
      type = lib.types.str;
      default = "postgresql";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5432;
    };
  };
  imports = [
    ./pgadmin.nix
  ];
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.unstable.postgresql_18;
      settings.port = cfg.port;
      enableTCPIP = true;
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
