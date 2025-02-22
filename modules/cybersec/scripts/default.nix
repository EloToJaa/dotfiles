{pkgs, ...}: let
  # ghidra-auto = pkgs.writers.writePython3Bin "ghidra-auto" {
  #   libraries = with pkgs.python313Packages; [
  #     click
  #   ];
  # } (builtins.readFile ./scripts/ghidra-auto.py);
in {
  home.packages = [
    # ghidra-auto
  ];
}
