{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) dotfilesDirectory;
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
      flake = dotfilesDirectory;
    };

    environment.systemPackages = with pkgs.unstable; [
      nix-update
      nvd
    ];
  };
}
