{
  pkgs,
  inputs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    neovim

    # C / C++
    gcc
    gdb
    gnumake

    # Programming languages
    python3
    nodejs
    npm-check-updates
    go
    rustc

    # Package managers
    cargo

    # Formatters
    alejandra

    # LSP
    nixd
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    PATH = "${pkgs.lib.makeBinPath ["${config.home.homeDirectory}/.local/share/nvim/mason"]}:$PATH";
  };

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  programs.zsh.shellAliases = {
    vim = "nvim";
    vi = "nvim";
  };
}
