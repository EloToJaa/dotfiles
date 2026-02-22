{lib, ...}: {
  options.modules.dev.nvim = {
    enable = lib.mkEnableOption "Enable nvim";
  };
  imports = [
    ./nixvim.nix
    ./packages.nix
    ./setup.nix
    ./plugins
    ./config
    ./languages
  ];
}
