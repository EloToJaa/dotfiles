{inputs, ...}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./packages.nix
    ./nixvim.nix
    ./setup.nix
    ./plugins
    ./config
  ];
}
