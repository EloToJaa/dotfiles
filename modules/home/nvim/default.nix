{
  pkgs,
  inputs,
  config,
  ...
}: let
  shellAliases = {
    vim = "nvim";
    vi = "nvim";
    v = "nvim";
  };
in {
  home.packages = with pkgs; [
    neovim

    rustup

    # C / C++
    gcc
    gdb
    gnumake

    # Programming languages
    python3
    nodejs
    npm-check-updates
    go

    # Formatters
    alejandra
    rustfmt

    # LSP
    nixd
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PATH = "${pkgs.lib.makeBinPath ["${config.home.homeDirectory}/.local/share/nvim/mason"]}:${pkgs.lib.makeBinPath ["${config.home.homeDirectory}/go"]}:${pkgs.lib.makeBinPath ["${config.home.homeDirectory}/.cargo"]}:$PATH";
  };

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  programs = {
    zsh.shellAliases = shellAliases;
    nushell.shellAliases = shellAliases;
  };
}
