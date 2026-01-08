{lib, ...}: {
  options.modules.dev = {
    enable = lib.mkEnableOption "Enable dev module";
  };
  imports = [
    ./nvim
    ./scripts # personal scripts
    ./aoc.nix
    ./lazygit.nix
    ./leetcode.nix
    ./opencode.nix
    ./packages.nix # other packages
    ./variables.nix # environment variables
  ];
}
