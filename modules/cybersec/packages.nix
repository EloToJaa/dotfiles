{pkgs, ...}: {
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
    #pwntools
  ];
}
