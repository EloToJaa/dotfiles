{
  lib,
  config,
  ...
}: let
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    security.sudo-rs.enable = false;
    security.sudo = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = lib.mkForce true;
      extraConfig = ''
        Defaults pwfeedback
      '';
    };
  };
}
