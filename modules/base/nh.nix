{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.base.nh;
in {
  options.modules.base.nh = {
    enable = lib.mkEnableOption "Enable nh";
  };
  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      package = pkgs.unstable.nh;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };
      flake = "/home/${username}/Projects/dotfiles";
    };

    environment.systemPackages = with pkgs.unstable; [
      nix-update
      nix-output-monitor
      nvd
    ];
  };
}
