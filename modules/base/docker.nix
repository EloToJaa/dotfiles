{
  pkgs,
  variables,
  ...
}: {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  users.users.${variables.username}.extraGroups = ["docker"];
  # environment.systemPackages = with pkgs; [
  #   rootlesskit
  # ];
  security.wrappers = {
    docker-rootlesskit = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_bind_service+ep";
      source = "${pkgs.rootlesskit}/bin/rootlesskit";
    };
  };
}
