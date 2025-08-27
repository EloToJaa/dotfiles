{inputs, ...}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    # ./lazydocker
    ./lazygit
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
    ./nerdfonts.nix # fonts
    ./packages.nix # other packages
    ./shell.nix # shell programs
    ./sops.nix # secrets
    ./tldr.nix # tldr
    ./variables.nix # environment variables
  ];
}
