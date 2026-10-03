{pkgs, ...}: {
  yazi-chmod = pkgs.callPackage ./chmod.nix {};
  yazi-copy-file-contents = pkgs.callPackage ./copy-file-contents.nix {};
  yazi-diff = pkgs.callPackage ./diff.nix {};
  yazi-exifaudio = pkgs.callPackage ./exifaudio.nix {};
  yazi-git = pkgs.callPackage ./git.nix {};
  yazi-mount = pkgs.callPackage ./mount.nix {};
  yazi-ouch = pkgs.callPackage ./ouch.nix {};
  yazi-piper = pkgs.callPackage ./piper.nix {};
  yazi-relative-motions = pkgs.callPackage ./relative-motions.nix {};
  yazi-smart-enter = pkgs.callPackage ./smart-enter.nix {};
  yazi-smart-filter = pkgs.callPackage ./smart-filter.nix {};
  yazi-system-clipboard = pkgs.callPackage ./system-clipboard.nix {};
  yazi-theme-bat = pkgs.callPackage ./theme-bat.nix {};
  yazi-theme-yazi = pkgs.callPackage ./theme-yazi.nix {};
  yazi-toggle-pane = pkgs.callPackage ./toggle-pane.nix {};
}
