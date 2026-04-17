{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    programs = {
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        # pinentryFlavor = "";
      };
      nix-ld.enable = true;
      zsh.enable = true;
    };

    services.smartd.enable = true;

    security.rtkit.enable = true;
    security.sudo-rs = {
      enable = true;
      package = pkgs.unstable.sudo-rs;
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
  };
}
