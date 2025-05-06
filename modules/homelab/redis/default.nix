{
  variables,
  config,
  ...
}: let
  name = "redis";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 6379;
in {
  services.${name}.servers.main = {
    enable = true;
    dataDir = "${homelab.dataDir}${name}";
    port = port;
    openFirewall = true;
    user = name;
    group = group;
    requirePassFile = config.sops.secrets."${name}/password".path;
  };

  sops.secrets = {
    "${name}/password" = {
      owner = name;
    };
  };
}
