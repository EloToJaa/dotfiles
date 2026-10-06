{
  imports = [../../nixosModules/server.nix];

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];
}
