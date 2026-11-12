{
  inputs,
  lib,
  config,
  ...
}: let
  inherit (config.settings) username;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./config.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [../../homeModules/server.nix];
    }
  ];

  _module.args.host = "wsl";
  nixpkgs.hostPlatform = "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = username;
  };

  # WSL boots through the Windows host: no bootloader, initrd, disks or GPU setup.
  modules = {
    base = {
      bootloader.enable = lib.mkForce false;
      initrd.enable = lib.mkForce false;
      smartd.enable = lib.mkForce false;
    };
    shared.graphics.enable = lib.mkForce false;
  };
  srvos.boot.consoles = lib.mkForce [];
}
