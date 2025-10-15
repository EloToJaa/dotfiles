{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
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
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  imports = [
    ./pgadmin.nix
  ];
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      inherit (cfg) dataDir;
      enable = true;
      package = pkgs.unstable.postgresql_16;
      settings.port = cfg.port;
      enableTCPIP = true;
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
