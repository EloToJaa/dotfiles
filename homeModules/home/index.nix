{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.modules.home.index;
in {
  options.modules.home.index = {
    enable = lib.mkEnableOption "Enable index";
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables.COMMA_NIXPKGS_FLAKE = "path:${inputs.nixpkgs-unstable.outPath}";
    programs.nix-index-database.comma.enable = true;
  };
}
