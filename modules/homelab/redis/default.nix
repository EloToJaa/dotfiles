{
  variables,
  config,
  ...
}: let
  name = "redis";
  group = variables.homelab.groups.database;
  port = 6379;
in {
  services.${name}.servers.main = {
    enable = true;
    # dataDir = "${homelab.dataDir}${name}";
    port = port;
    openFirewall = true;
    user = name;
    group = group;
    requirePassFile = config.sops.secrets."${name}/password".path;
  };

  users.users.${name} = {
    isSystemUser = true;
    description = "${name}";
    group = "${group}";
  };

  sops.secrets = {
    "${name}/password" = {
      owner = name;
    };
  };
}
