{variables, ...}: {
  virtualisation.docker.enable = true;
  users.users.${variables.username}.extraGroups = ["docker"];
}
