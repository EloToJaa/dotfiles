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

  # Nixbot integration point: import/enable the user's module here after merging it.
  # No nixbot service or flake dependency is defined until that integration exists.
}
