{
  inputs,
  lib,
  ...
}: {
  options.modules.home.nvim = {
    enable = lib.mkEnableOption "Enable nvim";
  };
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
