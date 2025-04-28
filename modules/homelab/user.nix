{variables, ...}: let
  homelab = variables.homelab;
in {
  users.users.${variables.username} = {
    extraGroups = ["${homelab.group}"];
  };

  users.groups.${homelab.group} = {};
}
