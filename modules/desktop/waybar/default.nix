{lib, ...}: {
  options.modules.desktop.waybar = {
    enable = lib.mkEnableOption "Enable waybar";
  };
  imports = [
    ./waybar.nix
    ./settings.nix
    ./style.nix
  ];
}
