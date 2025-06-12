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
    # neovim

    # rustup

    # C / C++
    gcc
    gdb
    gnumake

    # Programming languages
    (python312.withPackages (pypkgs:
      with pypkgs; [
        click
        requests
        flask
        pip
        pipx
        pwntools
        ropper
        # angr
        pycryptodome
      ]))
    uv

    nodejs
    bun
    npm-check-updates

    go
    sqlc
    goose

    elixir

    lua5_4
    lua54Packages.luarocks

    zig
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
    PATH = "${makeBinPath ["${homeDirectory}/go"]}:${makeBinPath ["${homeDirectory}/.cargo"]}:${makeBinPath ["${homeDirectory}/.local"]}:${homeDirectory}/.dotnet:$PATH";
  };

  # nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  programs = {
    zsh.shellAliases = shellAliases;
    nushell = {
      shellAliases = shellAliases;
      extraEnv = ''
        $env.Path = ($env.Path | prepend ["${makeBinPath ["${homeDirectory}/go"]}" "${makeBinPath ["${homeDirectory}/.cargo"]}" "${makeBinPath ["${homeDirectory}/.local"]}" "${homeDirectory}/.dotnet"]);
      '';
    };
  };
}
