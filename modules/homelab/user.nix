{variables, ...}: {
  users.users.${variables.username} = {
    extraGroups = ["homelab"];
  };
}
