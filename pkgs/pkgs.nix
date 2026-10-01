{
  pkgs,
  pyproject-build-systems,
  pyproject-nix,
  uv2nix,
  yamtrack-src,
  ...
}: {
  ai-agent-browser-skills = pkgs.callPackage ./ai/agent-browser-skills.nix {};
  ai-anthropics-skills = pkgs.callPackage ./ai/anthropics-skills.nix {};
  ai-mattpocock-skills = pkgs.callPackage ./ai/mattpocock-skills.nix {};
  ai-open-code-review-skills = pkgs.callPackage ./ai/open-code-review-skills.nix {};
  ai-pi-agent-extensions = pkgs.callPackage ./ai/pi-agent-extensions.nix {};
  ai-pi-vim = pkgs.callPackage ./ai/pi-vim.nix {};
  ai-workmux-skills = pkgs.callPackage ./ai/workmux-skills.nix {};
  cleanuparr = pkgs.callPackage ./cleanuparr {};
  energa-my-meter = pkgs.unstable.callPackage ./energa-my-meter {};
  jellystat = pkgs.callPackage ./jellystat {};
  musicseerr = pkgs.callPackage ./musicseerr {};
  oniri = pkgs.unstable.callPackage ./oniri {};
  stack-in-card = pkgs.callPackage ./stack-in-card {};
  streamystats = pkgs.callPackage ./streamystats {};
  tapo-control = pkgs.unstable.callPackage ./tapo-control {};
  dreame-vacuum = pkgs.unstable.callPackage ./dreame-vacuum {};
  webrtc = pkgs.unstable.callPackage ./webrtc {};
  webrtc-camera = pkgs.callPackage ./webrtc-camera {};
  yamtrack = pkgs.callPackage ./yamtrack {
    inherit pyproject-build-systems pyproject-nix uv2nix yamtrack-src;
  };
  yazi-chmod = pkgs.callPackage ./yazi/chmod.nix {};
  yazi-copy-file-contents = pkgs.callPackage ./yazi/copy-file-contents.nix {};
  yazi-diff = pkgs.callPackage ./yazi/diff.nix {};
  yazi-exifaudio = pkgs.callPackage ./yazi/exifaudio.nix {};
  yazi-git = pkgs.callPackage ./yazi/git.nix {};
  yazi-mount = pkgs.callPackage ./yazi/mount.nix {};
  yazi-ouch = pkgs.callPackage ./yazi/ouch.nix {};
  yazi-piper = pkgs.callPackage ./yazi/piper.nix {};
  yazi-relative-motions = pkgs.callPackage ./yazi/relative-motions.nix {};
  yazi-smart-enter = pkgs.callPackage ./yazi/smart-enter.nix {};
  yazi-smart-filter = pkgs.callPackage ./yazi/smart-filter.nix {};
  yazi-system-clipboard = pkgs.callPackage ./yazi/system-clipboard.nix {};
  yazi-theme-bat = pkgs.callPackage ./yazi/theme-bat.nix {};
  yazi-theme-yazi = pkgs.callPackage ./yazi/theme-yazi.nix {};
  yazi-toggle-pane = pkgs.callPackage ./yazi/toggle-pane.nix {};
}
