{variables, ...}: {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  users.users.${variables.username}.extraGroups = ["docker"];
}