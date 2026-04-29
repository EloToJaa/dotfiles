{lib, ...}: {
  options.modules.dev = {
    enable = lib.mkEnableOption "Enable dev module";
  };
  imports = [
    ./ai
    ./nvim
    ./scripts # personal scripts
    ./aoc.nix
    ./lazygit.nix
    ./leetcode.nix
    ./packages.nix # other packages
    ./zed.nix
    ./variables.nix # environment variables
  ];
}
