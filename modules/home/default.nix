{
  lib,
  config,
  ...
}: let
  cfg = config.modules.home;
in {
  options.modules.home = {
    enable = lib.mkEnableOption "Enable home module";
  };
  imports = [
    ./lazygit
    ./nvim
    ./oh-my-posh # shell prompt
    ./tmux
    ./yazi
    ./zsh # shell
    ./aliases.nix # shell aliases
    ./bat.nix # better cat command
    ./btop.nix # resouces monitor
    ./catppuccin.nix
    ./fastfetch.nix # fetch tool
    ./fzf.nix # fuzzy finder
    ./git.nix # version control
    ./index.nix
    ./nerdfonts.nix # fonts
    ./packages.nix # other packages
    ./shell.nix # shell programs
    ./sops.nix # secrets
    ./tldr.nix # tldr
    ./variables.nix # environment variables
  ];
}
