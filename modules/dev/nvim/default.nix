{inputs, ...}: {
  imports = [
    ./languages.nix
    ./nvf.nix
    ./setup.nix
    ./supermaven.nix
    inputs.nvf.homeManagerModules.default
  ];
}
