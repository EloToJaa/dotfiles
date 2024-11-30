{
  # pkgs,
  variables,
  ...
}: {
  # virtualisation.docker.enable = true;
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };
  # users.users.${variables.username}.extraGroups = ["docker"];
  # security.wrappers = {
  #   docker-rootlesskit = {
  #     owner = "root";
  #     group = "root";
  #     capabilities = "cap_net_bind_service+ep";
  #     source = "${pkgs.rootlesskit}/bin/rootlesskit";
  #   };
  # };
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  users.users.${variables.username} = {
    isNormalUser = true;
    extraGroups = ["podman"];
  };
}
