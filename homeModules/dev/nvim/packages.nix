{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (pkgs.lib) makeBinPath;
  inherit (config.home) homeDirectory;
  cfg = config.modules.dev.nvim;
in {
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      PATH = "${makeBinPath ["${homeDirectory}/go"]}:${makeBinPath ["${homeDirectory}/.cargo"]}:${makeBinPath ["${homeDirectory}/.local"]}:${homeDirectory}/.dotnet:$PATH";
    };
  };
}
