{...}: {
  imports = [
    ./nushell
    ./nvim # neovim editor
    ./scripts # personal scripts
    ./aliases.nix # shell aliases
    ./lazygit.nix
    ./packages.nix # other packages
    ./variables.nix # environment variables
  ];
}
