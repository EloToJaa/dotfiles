{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab;
in {
  config = lib.mkIf cfg.enable {
    services.redis.package = pkgs.unstable.redis;
  };
}
