{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.core.wayland;
in {
  imports = [inputs.niri-session-manager.nixosModules.niri-session-manager];

  config = lib.mkIf (cfg.enable && cfg.niri.enable) {
    programs.niri = {
      enable = true;
      package = pkgs.unstable.niri;
      useNautilus = true;
    };

    systemd.user.services.niri-flake-polkit.enable = false;

    services.niri-session-manager.enable = true;
    systemd.user.services.niri-session-manager.serviceConfig.ExecStart = lib.mkForce "${lib.getExe config.services.niri-session-manager.package} --save-interval 30 --max-backup-count 3";
  };
}
