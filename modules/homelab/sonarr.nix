{variables, ...}: let
  name = "sonarr";
  homelab = variables.homelab;
in {
  services.${name} = {
    enable = true;
    user = "${name}";
    group = "${homelab.group}";
    dataDir = "${homelab.dataDir}${name}";
  };

  systemd.tmpfiles.rules = [
    "d ${homelab.dataDir}${name} 750 ${name} ${homelab.group} - -"
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = "${name}";
    group = "${homelab.group}";
  };
}
