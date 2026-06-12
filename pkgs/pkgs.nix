{pkgs, ...}: {
  energa-my-meter = pkgs.callPackage ./energa-my-meter {};
  jellystat = pkgs.callPackage ./jellystat {};
}
