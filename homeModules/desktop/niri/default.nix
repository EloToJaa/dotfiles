{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  options.modules.desktop.niri = {
    enable = lib.mkEnableOption "Enable niri";
  };
  imports = [
    ./binds.nix
    ./settings.nix
    ./spawn.nix
    ./window-rules.nix
    ./workspaces.nix
  ];
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      xwayland-satellite-unstable
    ];
  };
}
