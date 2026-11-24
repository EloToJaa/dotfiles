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
    alloy.enable = true;
    nginx.enable = true;
    matrix = {
      enable = true;
      auth.enable = true;
    };
    forgejo = {
      enable = true;
      auth.enable = true;
    };
    stalwart.enable = true;
  };
}
