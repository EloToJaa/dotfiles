{
  variables,
  pkgs,
  ...
}: {
  programs.adb.enable = true;
  users.users.${variables.username} = {
    extraGroups = ["adbusers"];
  };
  home-manager.users.${variables.username} = {
    home.packages = with pkgs; [android-studio];
  };
}
