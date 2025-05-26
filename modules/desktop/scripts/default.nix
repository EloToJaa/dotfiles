{pkgs, ...}: let
  wall-change = pkgs.writeShellScriptBin "wall-change" (builtins.readFile ./scripts/wall-change.sh);
  wallpaper-picker = pkgs.writeShellScriptBin "wallpaper-picker" (builtins.readFile ./scripts/wallpaper-picker.sh);
  random-wallpaper = pkgs.writeShellScriptBin "random-wallpaper" (builtins.readFile ./scripts/random-wallpaper.sh);

  music = pkgs.writeShellScriptBin "music" (builtins.readFile ./scripts/music.sh);
  lofi = pkgs.writeScriptBin "lofi" (builtins.readFile ./scripts/lofi.sh);

  toggle-blur = pkgs.writeScriptBin "toggle-blur" (builtins.readFile ./scripts/toggle-blur.sh);
  toggle-opacity = pkgs.writeScriptBin "toggle-opacity" (builtins.readFile ./scripts/toggle-opacity.sh);
  toggle-waybar = pkgs.writeScriptBin "toggle-waybar" (builtins.readFile ./scripts/toggle-waybar.sh);
  toggle-float = pkgs.writeScriptBin "toggle-float" (builtins.readFile ./scripts/toggle-float.sh);

  show-keybinds = pkgs.writeScriptBin "show-keybinds" (builtins.readFile ./scripts/keybinds.sh);

  vm-start = pkgs.writeScriptBin "vm-start" (builtins.readFile ./scripts/vm-start.sh);

  record = pkgs.writeScriptBin "record" (builtins.readFile ./scripts/record.sh);

  screenshot = pkgs.writeScriptBin "screenshot" (builtins.readFile ./scripts/screenshot.sh);

  rofi-power-menu = pkgs.writeScriptBin "rofi-power-menu" (builtins.readFile ./scripts/rofi-power-menu.sh);
  power-menu = pkgs.writeScriptBin "power-menu" (builtins.readFile ./scripts/power-menu.sh);
in {
  home.packages = [
    wall-change
    wallpaper-picker
    random-wallpaper

    music
    lofi

    toggle-blur
    toggle-opacity
    toggle-waybar
    toggle-float

    show-keybinds

    vm-start

    record

    screenshot

    rofi-power-menu
    power-menu
  ];
}
