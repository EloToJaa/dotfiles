{variables, ...}: let
  homelab = variables.homelab;
in {
  users.users.${variables.username} = {
    extraGroups = [
      "${homelab.groups.main}"
      "${homelab.groups.media}"
      "${homelab.groups.photos}"
      "${homelab.groups.docs}"
      "${homelab.groups.database}"
    ];
  };

  users.groups = {
    ${homelab.groups.main}.gid = 1100;
    ${homelab.groups.media}.gid = 1101;
    ${homelab.groups.photos}.gid = 1102;
    ${homelab.groups.docs}.gid = 1103;
    ${homelab.groups.database}.gid = 1104;
  };
}
