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

    nodejs
    bun
    npm-check-updates

    sqlc
    goose

    elixir
  ];

  home.sessionVariables = {
    PATH = "${makeBinPath ["${homeDirectory}/go"]}:${makeBinPath ["${homeDirectory}/.cargo"]}:${makeBinPath ["${homeDirectory}/.local"]}:${homeDirectory}/.dotnet:$PATH";
  };

  programs.nushell.extraEnv = ''
    $env.Path = ($env.Path | prepend ["${makeBinPath ["${homeDirectory}/go"]}" "${makeBinPath ["${homeDirectory}/.cargo"]}" "${makeBinPath ["${homeDirectory}/.local"]}" "${homeDirectory}/.dotnet"]);
  '';
}
