{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  _module.args.host = "worker";
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  modules.shared = {
    cpu.vendor = "intel";
    graphics = {
      vendor = "intel";
      earlyBoot = false;
    };
  };
  imports = [
    inputs.srvos.nixosModules.server
    ./config.nix
    ./disko.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [
        ../../homeModules/server.nix
      ];
    }
  ];
}
