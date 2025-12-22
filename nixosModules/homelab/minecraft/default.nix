{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab.minecraft;
in {
  options.modules.homelab.minecraft = {
    enable = lib.mkEnableOption "Enable minecraft";
  };
  config = lib.mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      package = pkgs.unstable.papermcServers.papermc-1_21_9;
      eula = true;
      openFirewall = true;
      declarative = false;
      jvmOpts = "-Xms4092M -Xmx4092M";
    };
  };
}
