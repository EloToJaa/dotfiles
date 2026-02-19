{lib, ...}: {
  options.modules.dev = {
    enable = lib.mkEnableOption "Enable dev module";
  };
  imports = [
    ./nvim
    ./opencode
    ./scripts # personal scripts
    ./aoc.nix
    ./lazygit.nix
    ./leetcode.nix
    ./packages.nix # other packages
    ./variables.nix # environment variables
  ];
}
