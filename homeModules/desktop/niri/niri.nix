{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config =
    lib.mkIf cfg.enable {
    };
}
