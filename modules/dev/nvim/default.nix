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
  makeBinPath = pkgs.lib.makeBinPath;
  homeDirectory = config.home.homeDirectory;
in {
  home.packages = with pkgs; [
    neovim

    rustup

    # C / C++
    gcc
    gdb
    gnumake

    # Programming languages
    # (python313.withPackages (pypkgs:
    #   with pypkgs; [
    #     click
    #     requests
    #   ]))
    python313
    uv
    nodejs
    npm-check-updates
    go
    elixir

    lua5_4
    lua54Packages.luarocks

    # Zig
    # inputs.zig.packages.${pkgs.system}.master
    zig
    # inputs.zls.packages.${pkgs.system}.zls

    # Formatters
    alejandra

    # LSP
    nixd
    clang-tools
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
    PATH = "${makeBinPath ["${homeDirectory}/.local/share/nvim/mason"]}:${makeBinPath ["${homeDirectory}/go"]}:${makeBinPath ["${homeDirectory}/.cargo"]}:$PATH";
  };

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  programs = {
    zsh.shellAliases = shellAliases;
    nushell = {
      shellAliases = shellAliases;
      extraEnv = ''
        $env.Path = ($env.Path | prepend ["${makeBinPath ["${homeDirectory}/.local/share/nvim/mason"]}" "${makeBinPath ["${homeDirectory}/go"]}" "${makeBinPath ["${homeDirectory}/.cargo"]}"]);
      '';
    };
  };
}
