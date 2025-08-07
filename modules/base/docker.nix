{
  variables,
  pkgs,
  ...
}: {
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

  users.users.${variables.username} = {
    extraGroups = ["docker"];
    linger = true;
  };

  environment.systemPackages = with pkgs.unstable; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
    #podman-compose # start group of containers for dev
  ];
}
