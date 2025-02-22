{pkgs, ...}: let
  ghidra-auto = pkgs.writeShellScriptBin "ghidra-auto" (builtins.readFile ./scripts/ghidra-auto.py);
in {
  home.packages = [
    ghidra-auto
  ];
}
