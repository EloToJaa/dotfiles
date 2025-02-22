{pkgs, ...}: let
  pypkgs = pkgs.python313Packages;
  ghidra-auto = pkgs.writers.writePython3Bin "ghidra-auto" {
    libraries = [
      pypkgs.click
    ];
  } (builtins.readFile ./scripts/ghidra-auto.py);
in {
  home.packages = [
    ghidra-auto
  ];
}
