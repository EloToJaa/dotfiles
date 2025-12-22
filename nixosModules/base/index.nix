{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.base.index;
in {
  options.modules.base.index = {
    enable = lib.mkEnableOption "Enable nix-index";
  };
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  config = lib.mkIf cfg.enable {
    programs = {
      nix-index-database.comma.enable = true;
      command-not-found.enable = true;
    };
  };
}
