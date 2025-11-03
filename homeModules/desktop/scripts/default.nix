{
  pkgs,
  lib,
  config,
  ...
}: let
  scriptDir = ./scripts;
  scriptEntries = builtins.readDir scriptDir;

  regularFiles = builtins.filter (name: scriptEntries.${name} == "regular") (
    builtins.attrNames scriptEntries
  );

  shellScripts =
    builtins.filter (
      name: builtins.match ".*\\.sh$" name != null
    )
    regularFiles;

  mkScript = name: {
    inherit name;
    value = pkgs.writeScriptBin (builtins.replaceStrings [".sh"] [""] name) (
      builtins.readFile (scriptDir + "/${name}")
    );
  };

  scriptsSet = builtins.listToAttrs (map mkScript shellScripts);
  scripts = builtins.attrValues scriptsSet;
  cfg = config.modules.desktop;
in {
  config = lib.mkIf cfg.enable {
    home.packages = scripts;
  };
}
