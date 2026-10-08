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
    nixbot.enable = true;
    nginx = {
      enable = true;
      group = "nginx";
    };
    matrix = {
      enable = true;
      serverName = "elotoja.com";
      endpointDomain = "matrix.elotoja.com";
    };
  };
}
