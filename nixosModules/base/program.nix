{
  pkgs,
  config,
  lib,
  ...
}: let
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
      zsh = {
        enable = true;
      };
    };

    services.smartd.enable = true;

    security.rtkit.enable = true;
    security.sudo-rs = {
      enable = true;
      package = pkgs.unstable.sudo-rs;
    };
  };
}
