{
  config,
  lib,
  ...
}: let
  cfg = config.modules.shared.index;
in {
  options.modules.shared.index = {
    enable = lib.mkEnableOption "Enable nix-index";
  };
  config = lib.mkIf cfg.enable {
    programs = {
      nix-index-database.comma.enable = true;
      # command-not-found.enable = true;
    };
  };
}
