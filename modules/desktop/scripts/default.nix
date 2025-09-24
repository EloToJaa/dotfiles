{pkgs, ...}: let
  wall-change = pkgs.writeShellScriptBin "wall-change" (builtins.readFile ./scripts/wall-change.sh);
  random-wallpaper = pkgs.writeShellScriptBin "random-wallpaper" (builtins.readFile ./scripts/random-wallpaper.sh);

  toggle-blur = pkgs.writeScriptBin "toggle-blur" (builtins.readFile ./scripts/toggle-blur.sh);
  toggle-opacity = pkgs.writeScriptBin "toggle-opacity" (builtins.readFile ./scripts/toggle-opacity.sh);
  toggle-waybar = pkgs.writeScriptBin "toggle-waybar" (builtins.readFile ./scripts/toggle-waybar.sh);
  toggle-float = pkgs.writeScriptBin "toggle-float" (builtins.readFile ./scripts/toggle-float.sh);

  record = pkgs.writeScriptBin "record" (builtins.readFile ./scripts/record.sh);

  screenshot = pkgs.writeScriptBin "screenshot" (builtins.readFile ./scripts/screenshot.sh);
in {
  home.packages = [
    wall-change
    random-wallpaper

    toggle-blur
    toggle-opacity
    toggle-waybar
    toggle-float

    record

    screenshot
  ];
}
