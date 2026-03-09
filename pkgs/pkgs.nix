{pkgs, ...}: {
  btca = pkgs.callPackage ./btca {};
  jellystat = pkgs.callPackage ./jellystat {};
  seerr = pkgs.callPackage ./seerr {};
}
