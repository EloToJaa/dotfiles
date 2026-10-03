{
  lib,
  config,
  ...
}: let
  cfg = config.modules.base.sudo;
in {
  options.modules.base.sudo = {
    enable = lib.mkEnableOption "Enable sudo with password authentication and shared credential caching";
  };

  config = lib.mkIf (config.modules.base.enable && cfg.enable) {
    security.sudo-rs.enable = false;
    security.sudo = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = lib.mkForce true;
      extraConfig = ''
        Defaults pwfeedback
        # Reuse authentication across Clan's separate SSH commands.
        Defaults:${config.settings.username} timestamp_type=global,timestamp_timeout=60
      '';
    };
  };
}
