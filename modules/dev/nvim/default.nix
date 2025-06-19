{inputs, ...}: {
  imports = [
    ./packages.nix
    ./nixvim.nix
    ./setup.nix
    ./plugins
    ./config
    inputs.nixvim.homeModules.nixvim
  ];
}
