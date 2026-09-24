{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.home.nix;
in {
  options.modules.home.nix = {
    enable = lib.mkEnableOption "Enable nix";
  };
  config = lib.mkIf cfg.enable {
    nix.nixPath = ["nixpkgs=${inputs.nixpkgs-unstable.outPath}"];

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
