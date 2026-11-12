{
  lib,
  config,
  ...
}: let
  inherit (config.settings) username;
in {
  imports = [../../nixosModules/server.nix];

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

  # WSL shares the Windows host's network and has no real NICs to manage.
  networking = {
    networkmanager.enable = lib.mkForce false;
    useDHCP = lib.mkForce false;
  };
  powerManagement.cpuFreqGovernor = lib.mkForce null;
}
