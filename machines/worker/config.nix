{
  imports = [../../nixosModules/server.nix];

  modules.homelab = {
    nixbot.enable = true;
    nginx.enable = true;
  };

  services.nixbot.evalMaxMemorySize = 16 * 1024;

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];
}
