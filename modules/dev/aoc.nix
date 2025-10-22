{
  pkgs,
  config,
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

    sops.secrets = {
      "aoc/session" = {};
    };

    sops.templates = {
      "adventofcode.session" = {
        content = "${config.sops.placeholder."aoc/session"}";
        path = "${config.home.homeDirectory}/.config/adventofcode.session";
      };
    };
  };
}
