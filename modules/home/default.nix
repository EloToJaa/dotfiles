{...}: {
  imports = [
    ./ohmyposh # shell prompt
    ./yazi
    ./zsh # shell
    ./aliases.nix # shell aliases
    ./bat.nix # better cat command
    ./btop.nix # resouces monitor
    ./catppuccin.nix
    ./fastfetch.nix # fetch tool
    ./fzf.nix # fuzzy finder
    ./git.nix # version control
    ./lazygit.nix
    ./nerdfonts.nix # fonts
    ./packages.nix # other packages
    ./shell.nix # shell programs
    ./sops.nix # secrets
    ./variables.nix # environment variables
  ];
}
