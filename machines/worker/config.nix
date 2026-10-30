{
  imports = [../../nixosModules/server.nix];

  modules.homelab = {
    harmonia.enable = true;
    nixbot.enable = true;
    t3-code.enable = true;
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
