{
  pkgs,
  inputs,
  ...
}: {
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
    ghidra
    inputs.pwndbg.packages.${pkgs.system}.pwndbg

    # pypkgs.pwntools
    # pypkgs.ropper
  ];
}
