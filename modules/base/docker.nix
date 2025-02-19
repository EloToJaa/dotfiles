{
  pkgs,
  variables,
  ...
}: {
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = false;
      daemon.settings = {
        debug = true;
        "log-driver" = "loki";
        "log-opts" = {
          "loki-url" = "https://loki.local.elotoja.com/loki/api/v1/push";
          "loki-batch-size" = "400";
          "loki-external-labels" = "container_name={{.Name}},hostname={{.Node.Hostname}}";
        };
      };
    };
  };
  users.users.${variables.username} = {
    extraGroups = ["docker"];
    linger = true;
  };
  security.wrappers = {
    docker-rootlesskit = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_bind_service+ep";
      source = "${pkgs.rootlesskit}/bin/rootlesskit";
    };
  };
}
