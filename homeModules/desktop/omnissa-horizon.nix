{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop.omnissa-horizon;
in {
  options.modules.desktop.omnissa-horizon = {
    enable = lib.mkEnableOption "Enable omnissa-horizon module";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.unstable.omnissa-horizon-client];
  };
}
