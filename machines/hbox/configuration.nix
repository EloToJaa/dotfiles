{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  imports = [
    inputs.srvos.nixosModules.server
    ./config.nix
    ./disko.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [../../homeModules/server.nix];
    }
  ];

  _module.args.host = "hbox";
  networking.hostName = "hbox";
  nixpkgs.hostPlatform = "x86_64-linux";
  modules.shared.btrfs = {
    scrub.enable = true;
    snapshots = {
      enable = true;
      subvolumes = {
        root = "/";
        nix = "/nix";
        var-lib = "/var/lib";
      };
    };
  };
  # Hetzner Cloud x86_64 VM, not Hetzner dedicated hardware.
  # Disko also contributes a GRUB device for the BIOS partition; keep one entry.
  boot.loader.grub.devices = lib.mkForce [config.disko.devices.disk.main.device];
}
