{inputs, ...}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./nixvim.nix
    ./packages.nix
    ./setup.nix
    ./plugins
    ./config
    ./languages
  ];
}
