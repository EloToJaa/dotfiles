{
  variables,
  pkgs,
  ...
}: {
  programs.adb.enable = true;
  users.users.${variables.username} = {
    extraGroups = ["adbusers"];
    home.packages = with pkgs; [android-studio];
  };
}
