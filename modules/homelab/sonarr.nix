{variables, ...}: let
  name = "sonarr";
  homelab = variables.homelab;
in {
  services.${name} = {
    enable = true;
    user = "${name}";
    group = "${name}";
    dataDir = "${homelab.dataDir}${name}";
  };

  users.users.${name} = {
    isSystemUser = true;
    description = "${name}";
    group = "homelab";
  };
}
