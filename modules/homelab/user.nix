{variables, ...}: let
  homelab = variables.homelab;
in {
  users.users.${variables.username} = {
    extraGroups = [
      "${homelab.groups.main}"
      "${homelab.groups.media}"
    ];
  };

  users.groups = {
    ${homelab.groups.main}.gid = 1100;
    ${homelab.groups.media}.gid = 1101;
  };
}
