{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  needsreboot = inputs.nixos-needsreboot.packages.${pkgs.stdenv.hostPlatform.system}.default;
  cfg = config.modules.base.bootloader;
in {
  options.modules.base.bootloader = {
    enable = lib.mkEnableOption "Enable bootloader";
  };
  config = lib.mkIf cfg.enable {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
        efi.canTouchEfiVariables = true;
      };
      kernel.sysctl = {
        "fs.inotify.max_user_watches" = 524288;
        "fs.inotify.max_user_instances" = 1024;
        "fs.inotify.max_queued_events" = 32768;
      };

      kernelPackages = pkgs.linuxPackages_latest;
    };

    systemd.package = pkgs.systemd;

    environment.systemPackages = [
      needsreboot
    ];

    system.activationScripts.nixos-needsreboot = {
      supportsDryActivation = true;
      text = "${
        lib.getExe needsreboot
      } \"$systemConfig\" || true";
    };
    # To prevent getting stuck at shutdown
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
  };
}
