{
  pkgs,
  config,
  lib,
  ...
}: let
  ghidra-auto = pkgs.writers.writePython3Bin "ghidra-auto" {
    libraries = with pkgs.unstable.python3Packages; [
      click
    ];
  } (builtins.readFile ./scripts/ghidra-auto.py);
  cfg = config.modules.cybersec;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      ghidra-auto
    ];
  };
}
