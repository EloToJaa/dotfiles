{inputs, ...}: {
  imports = [
    ./languages.nix
    ./nvf.nix
    inputs.nvf.homeManagerModules.default
  ];
}
