{pkgs}: let
  inherit (pkgs) lib;
  # Export the same definitions consumed by Home Manager for CI and updates.
  fromDirectory = prefix: directory:
    lib.mapAttrs' (filename: _:
      lib.nameValuePair
      "${prefix}-${lib.removeSuffix ".nix" filename}"
      (pkgs.callPackage (directory + "/${filename}") {}))
    (lib.filterAttrs (filename: type: type == "regular" && lib.hasSuffix ".nix" filename)
      (builtins.readDir directory));
in
  (fromDirectory "yazi" ./yazi)
  // (fromDirectory "ai" ./ai)
