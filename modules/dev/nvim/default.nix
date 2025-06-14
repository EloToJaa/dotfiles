{inputs, ...}: {
  imports = [
    ./languages.nix
    ./nvf.nix
    ./setup.nix
    inputs.nvf.homeManagerModules.default
  ];
}
