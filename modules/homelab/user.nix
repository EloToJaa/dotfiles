{variables, ...}: {
  users.users.${variables.username} = {
    extraGroups = ["${variables.homelab.group}"];
  };
}
