{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}: let
  cfg = config.modules.dev.aoc;
in {
  options.modules.dev.aoc = {
    enable = lib.mkEnableOption "Enable adventofcode module";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      aoc-cli
    ];

    home.file.".config/adventofcode.session".source =
      config.lib.file.mkOutOfStoreSymlink osConfig.clan.core.vars.generators.aoc.files.session.path;
  };
}
