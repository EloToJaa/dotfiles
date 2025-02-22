{pkgs, ...}: let
  ghidra-auto = pkgs.python3.withPackages (ps:
    with ps; [
      click
    ])
  (pkgs.writePython3Bin "ghidra-auto" ./scripts/ghidra-auto.py);
in {
  home.packages = [
    ghidra-auto
  ];
}
