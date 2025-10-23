{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.base.docker;
in {
  options.modules.base.docker = {
    enable = lib.mkEnableOption "Enable docker";
  };
  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      package = pkgs.unstable.podman;

      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [
          "--filter=until=24h"
          "--filter=label!=important"
        ];
      };
    };
    virtualisation.oci-containers.backend = "podman";

    users.users.${username} = {
      extraGroups = ["docker"];
      linger = true;
    };
  };
}
