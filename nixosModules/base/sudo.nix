{
  lib,
  config,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    security.sudo-rs.enable = false;
    security.sudo = {
      enable = true;
      execWheelOnly = lib.mkForce false;
      extraConfig = ''
        Defaults pwfeedback
      '';
      extraRules = [
        {
          users = [username];
          commands = [
            {
              command = "/run/current-system/sw/bin/podman";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };
}
