{
  pkgs,
  config,
  ...
}: let
  inherit (pkgs.lib) makeBinPath;
  inherit (config.home) homeDirectory;
in {
  home.sessionVariables = {
    PATH = "${makeBinPath ["${homeDirectory}/go"]}:${makeBinPath ["${homeDirectory}/.cargo"]}:${makeBinPath ["${homeDirectory}/.local"]}:${homeDirectory}/.dotnet:$PATH";
  };
}
