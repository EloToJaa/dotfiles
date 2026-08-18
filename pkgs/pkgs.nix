{pkgs, ...}: {
  cleanuparr = pkgs.callPackage ./cleanuparr {};
  energa-my-meter = pkgs.unstable.callPackage ./energa-my-meter {};
  jellystat = pkgs.callPackage ./jellystat {};
  musicseerr = pkgs.callPackage ./musicseerr {};
  dreame-vacuum = pkgs.unstable.callPackage ./dreame-vacuum {};
}
