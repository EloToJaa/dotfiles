{
  imports = [
    ./../../nixosModules/server.nix
  ];
  modules.homelab = {
    enable = true;
  };
}
