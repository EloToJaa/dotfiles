{lib, ...}: {
  imports = [
    ../../nixosModules/server.nix
    ../../nixosModules/vm.nix
  ];

  settings.dns = ["1.1.1.1" "9.9.9.9"];
  networking = {
    networkmanager.enable = lib.mkForce false;
    useNetworkd = true;
    useDHCP = false;
  };

  modules.homelab = {
    nginx.enable = true;
    matrix.enable = true;
  };
}
