{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.cybersec;
in {
  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        rustscan
        gobuster
        bettercap
      ])
      ++ (with pkgs.unstable; [
        # Recon
        nmap
        ffuf
        feroxbuster
        caido
        wpscan

        # Exploit
        sqlmap
        metasploit

        # Reverse Engineering
        ghidra
        inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.pwndbg
      ]);
  };
}
