{
  pkgs,
  pyproject-build-systems,
  pyproject-nix,
  uv2nix,
  yamtrack-src,
  ...
}:
(import ./ai {inherit pkgs;})
// (import ./yazi {inherit pkgs;})
// {
  cleanuparr = pkgs.callPackage ./cleanuparr {};
  energa-my-meter = pkgs.unstable.callPackage ./energa-my-meter {};
  jellystat = pkgs.callPackage ./jellystat {};
  musicseerr = pkgs.callPackage ./musicseerr {};
  oniri = pkgs.unstable.callPackage ./oniri {};
  stack-in-card = pkgs.callPackage ./stack-in-card {};
  streamystats = pkgs.callPackage ./streamystats {};
  tapo-control = pkgs.unstable.callPackage ./tapo-control {};
  tmux-smart-splits = pkgs.callPackage ./tmux-smart-splits {};
  dreame-vacuum = pkgs.unstable.callPackage ./dreame-vacuum {};
  zsh-auto-notify = pkgs.callPackage ./zsh-auto-notify {};
  webrtc = pkgs.unstable.callPackage ./webrtc {};
  webrtc-camera = pkgs.callPackage ./webrtc-camera {};
  yamtrack = pkgs.callPackage ./yamtrack {
    inherit pyproject-build-systems pyproject-nix uv2nix yamtrack-src;
  };
}
