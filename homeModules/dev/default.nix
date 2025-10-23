{lib, ...}: {
  options.modules.dev = {
    enable = lib.mkEnableOption "Enable dev module";
  };
  imports = [
    ./scripts # personal scripts
    ./aoc.nix
    ./leetcode.nix
    ./opencode.nix
    ./packages.nix # other packages
    ./variables.nix # environment variables
  ];
}
