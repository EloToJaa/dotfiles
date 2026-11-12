{lib, ...}: {
  imports = [../../nixosModules/server.nix];

  # WSL shares the Windows host's network and has no real NICs to manage.
  networking = {
    networkmanager.enable = lib.mkForce false;
    useDHCP = lib.mkForce false;
  };
  powerManagement.cpuFreqGovernor = lib.mkForce null;
}
