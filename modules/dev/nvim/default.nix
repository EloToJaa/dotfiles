{inputs, ...}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./nixvim.nix
    ./packages.nix
    ./setup.nix
    ./plugins
    ./config
    ./languages
  ];
}
