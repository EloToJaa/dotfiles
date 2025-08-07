{variables, ...}: {
  programs.adb = {
    enable = true;
  };
  users.users.${variables.username} = {
    extraGroups = ["adbusers"];
  };
}
