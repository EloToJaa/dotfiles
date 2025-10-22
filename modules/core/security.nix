{
  config,
  lib,
  ...
}: let
  inherit (config.modules.settings) username;
  cfg = config.modules.core.security;
in {
  options.modules.core.security = {
    enable = lib.mkEnableOption "Enable security module";
  };
  config = lib.mkIf cfg.enable {
    security.sudo-rs = {
      extraRules = [
        {
          users = [username];
          commands = [
            {
              command = "ALL";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
    security.pam.services.hyprlock = {};
  };
}
