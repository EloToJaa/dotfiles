{pkgs, ...}: {
  btca = pkgs.callPackage ./btca {};
  bazarr = pkgs.callPackage ./bazarr.nix {};
}
