{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.home.index;
in {
  options.modules.home.nix = {
    enable = lib.mkEnableOption "Enable nix";
  };
  config = lib.mkIf cfg.enable {
    programs.nix-your-shell = {
      enable = true;
      enableZshIntegration = true;
      package = pkgs.unstable.nix-your-shell;
      nix-output-monitor = {
        enable = true;
        package = pkgs.unstable.nix-output-monitor;
      };
    };
  };
}
