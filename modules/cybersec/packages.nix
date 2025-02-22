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

    (pkgs.python3.withPackages (pypkgs:
      with pypkgs; [
        click
        requests
        pwntools
        ropper
      ]))
  ];
}
