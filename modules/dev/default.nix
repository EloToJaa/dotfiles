{...}: {
  imports = [
    ./nvim
    ./scripts # personal scripts
    # ./tmux
    ./aliases.nix # shell aliases
    ./coding.nix # leetcode cli
    ./packages.nix # other packages
    ./variables.nix # environment variables
  ];
}
