{inputs, ...}: {
  imports = [
    ./packages.nix
    ./nvf.nix
    ./setup.nix
    ./plugins
    ./config
    inputs.nvf.homeManagerModules.default
  ];
}
