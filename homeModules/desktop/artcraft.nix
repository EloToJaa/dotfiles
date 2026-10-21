{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.artcraft;
  craftapps = inputs.craftapps.packages.${pkgs.stdenv.hostPlatform.system};
  apps = {
    cadcraft = "CAD and drafting";
    deckcraft = "presentations";
    designcraft = "page layout and publishing";
    effectcraft = "motion graphics and VFX";
    figcraft = "interface design and prototyping";
    filmcraft = "video editor";
    gridcraft = "spreadsheet";
    lightcraft = "photo library and raw processor";
    pdfcraft = "PDF reader and editor";
    photocraft = "image editor";
    soundcraft = "audio workstation";
    vectorcraft = "vector illustration";
    wordcraft = "word processor";
  };
in {
  options.modules.desktop.artcraft =
    lib.mapAttrs (name: description: {
      enable = lib.mkEnableOption "${name} (${description})";
    })
    apps;
  config = {
    home.packages = lib.pipe apps [
      lib.attrNames
      (lib.filter (name: cfg.${name}.enable))
      (map (name: craftapps.${name}))
    ];
  };
}
