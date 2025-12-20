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

      kernelPackages = pkgs.linuxPackages_latest;
    };
    systemd.package = pkgs.systemd;

    environment.systemPackages = [
      needsreboot
    ];

    system = {
      activationScripts.nixos-needsreboot = {
        supportsDryActivation = true;
        text = "${
          lib.getExe needsreboot
        } \"$systemConfig\" || true";
      };
      # nixos.label = "-";
    };
    # To prevent getting stuck at shutdown
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
  };
}
