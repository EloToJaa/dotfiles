{inputs, ...}: {
  imports = [
    ./languages.nix
    ./nvf.nix
    ./setup.nix
    # ./plugins
    inputs.nvf.homeManagerModules.default
  ];
}
