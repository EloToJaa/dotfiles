{
  lib,
  config,
  ...
}: let
  cfg = config.modules.homelab;
in {
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      enable = lib.mkForce true;
    };
  };
}
