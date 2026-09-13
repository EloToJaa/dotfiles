{
  pkgs,
  pyproject-build-systems,
  pyproject-nix,
  uv2nix,
  yamtrack-src,
  ...
}: {
  cleanuparr = pkgs.callPackage ./cleanuparr {};
  energa-my-meter = pkgs.unstable.callPackage ./energa-my-meter {};
  jellystat = pkgs.callPackage ./jellystat {};
  musicseerr = pkgs.callPackage ./musicseerr {};
  stack-in-card = pkgs.callPackage ./stack-in-card {};
  tapo-control = pkgs.unstable.callPackage ./tapo-control {};
  dreame-vacuum = pkgs.unstable.callPackage ./dreame-vacuum {};
  webrtc = pkgs.unstable.callPackage ./webrtc {};
  webrtc-camera = pkgs.callPackage ./webrtc-camera {};
  yamtrack = pkgs.callPackage ./yamtrack {
    inherit pyproject-build-systems pyproject-nix uv2nix yamtrack-src;
  };
}
