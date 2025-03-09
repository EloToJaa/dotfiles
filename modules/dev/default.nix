{...}: {
  imports = [
    ./nushell
    ./nvim # neovim editor
    ./scripts # personal scripts
    ./aliases.nix # shell aliases
    ./coding.nix # leetcode cli
    ./packages.nix # other packages
    ./variables.nix # environment variables
  ];
}
