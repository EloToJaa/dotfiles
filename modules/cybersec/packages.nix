{pkgs, ...}: let
  pypkgs = pkgs.python313Packages;
in {
  home.packages = with pkgs; [
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
    ghidra-bin
    pwndbg

    pypkgs.pwntools
    pypkgs.ropper
  ];
}
