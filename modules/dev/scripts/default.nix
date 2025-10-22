{
  pkgs,
  config,
  lib,
  ...
}: let
  ascii = pkgs.writeScriptBin "ascii" (builtins.readFile ./scripts/ascii.sh);
  maxfetch = pkgs.writeScriptBin "maxfetch" (builtins.readFile ./scripts/maxfetch.sh);
  runbg = pkgs.writeShellScriptBin "runbg" (builtins.readFile ./scripts/runbg.sh);
  cfg = config.modules.dev;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      ascii
      maxfetch
      runbg
    ];
  };
}
