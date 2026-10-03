{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.shared.containers;
in {
  options.modules.shared.containers = {
    enable = lib.mkEnableOption "Enable Podman containers";
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
    environment.systemPackages = with pkgs.unstable; [
      podman-compose
    ];

    users.users.${username} = {
      linger = true;
    };
  };
}
