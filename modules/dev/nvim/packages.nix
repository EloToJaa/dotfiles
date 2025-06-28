{
  pkgs,
  config,
  ...
}: let
  makeBinPath = pkgs.lib.makeBinPath;
  homeDirectory = config.home.homeDirectory;
in {
  home.packages = with pkgs; [
    # rustup

    # C / C++
    gcc
    gdb
    gnumake

    nodejs
    bun
    npm-check-updates

    go
    sqlc
    goose

    elixir

    zig
  ];

  home.sessionVariables = {
    PATH = "${makeBinPath ["${homeDirectory}/go"]}:${makeBinPath ["${homeDirectory}/.cargo"]}:${makeBinPath ["${homeDirectory}/.local"]}:${homeDirectory}/.dotnet:$PATH";
  };

  programs.nushell.extraEnv = ''
    $env.Path = ($env.Path | prepend ["${makeBinPath ["${homeDirectory}/go"]}" "${makeBinPath ["${homeDirectory}/.cargo"]}" "${makeBinPath ["${homeDirectory}/.local"]}" "${homeDirectory}/.dotnet"]);
  '';
}
