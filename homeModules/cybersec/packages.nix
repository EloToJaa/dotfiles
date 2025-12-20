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
    home.packages = with pkgs.unstable; [
      # Recon
      nmap
      rustscan
      ffuf
      gobuster
      feroxbuster
      caido
      wpscan

      # Exploit
      sqlmap
      bettercap
      metasploit

      # Reverse Engineering
      ghidra
      inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.pwndbg
    ];
  };
}
