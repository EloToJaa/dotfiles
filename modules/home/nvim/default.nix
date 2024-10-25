{pkgs, ...}: {
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
  ];

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  programs.zsh.shellAliases = {
    vim = "nvim";
    vi = "nvim";
  };
}
