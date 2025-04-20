{
  pkgs,
  variables,
  host,
  ...
}: let
  loki =
    if (host == "desktop" || host == "server")
    then variables.loki.local
    else variables.loki.remote;
in {
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = false;
      daemon.settings = {
        debug = true;
        #   "log-driver" = "loki";
        #   "log-opts" = {
        #     "loki-url" = "${loki}/loki/api/v1/push";
        #     "loki-batch-size" = "400";
        #     "loki-external-labels" = "container_name={{.Name}},hostname={{.Node.Hostname}}";
        #     "loki-retries" = "2";
        #     "loki-max-backoff" = "800ms";
        #     "loki-timeout" = "1s";
        #     "keep-file" = "true";
        #     "mode" = "non-blocking";
        #   };
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
