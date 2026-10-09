{lib, ...}: {
  imports = [../../nixosModules/server.nix];

  modules.homelab = {
    nixbot.enable = true;
    nginx.enable = true;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];
}
