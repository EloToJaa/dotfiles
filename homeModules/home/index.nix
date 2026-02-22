{
  config,
  lib,
  ...
}: let
  cfg = config.modules.home.index;
in {
  options.modules.home.index = {
    enable = lib.mkEnableOption "Enable index";
  };
  config = lib.mkIf cfg.enable {
    programs.nix-index-database.comma.enable = true;
  };
}
