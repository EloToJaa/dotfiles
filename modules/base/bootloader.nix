{
  pkgs,
  inputs,
  lib,
  ...
}: let
  needsreboot = inputs.nixos-needsreboot.packages.${pkgs.system}.default;
in {
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
  systemd.package = inputs.systemd-nixpkgs.legacyPackages.${pkgs.system}.systemd;

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
    nixos.label = "-";
  };
}
