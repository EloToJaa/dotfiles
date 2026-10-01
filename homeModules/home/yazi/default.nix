{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.home.yazi;
in {
  options.modules.home.yazi = {
    enable = lib.mkEnableOption "Enable yazi";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      exiftool
      jq
      ffmpeg
      ffmpegthumbnailer
      imagemagick
      poppler
      ripgrep # grep replacement
      ripgrep-all # rg for more file types, optional
      fd # find replacement
      file # Show file information
      resvg
      (ouch.override {enableUnfree = true;})
      glow
      mediainfo
      hexyl
      udisks
      yazi
    ];

    xdg.configFile = {
      "yazi/yazi.toml".source = ./yazi.toml;
      "yazi/keymap.toml".source = ./keymap.toml;
      "yazi/init.lua".source = ./init.lua;

      # Theme
      "yazi/Catppuccin-mocha.tmTheme".source = pkgs.callPackage ../../../pkgs/yazi/theme-bat.nix {};
      "yazi/theme.toml".source = pkgs.callPackage ../../../pkgs/yazi/theme-yazi.nix {};

      # Plugins
      "yazi/plugins/git.yazi".source = pkgs.callPackage ../../../pkgs/yazi/git.nix {};
      "yazi/plugins/smart-filter.yazi".source = pkgs.callPackage ../../../pkgs/yazi/smart-filter.nix {};
      "yazi/plugins/smart-enter.yazi".source = pkgs.callPackage ../../../pkgs/yazi/smart-enter.nix {};
      "yazi/plugins/mount.yazi".source = pkgs.callPackage ../../../pkgs/yazi/mount.nix {};
      "yazi/plugins/chmod.yazi".source = pkgs.callPackage ../../../pkgs/yazi/chmod.nix {};
      "yazi/plugins/diff.yazi".source = pkgs.callPackage ../../../pkgs/yazi/diff.nix {};
      "yazi/plugins/copy-file-contents.yazi".source = pkgs.callPackage ../../../pkgs/yazi/copy-file-contents.nix {};
      "yazi/plugins/system-clipboard.yazi".source = pkgs.callPackage ../../../pkgs/yazi/system-clipboard.nix {};
      "yazi/plugins/exifaudio.yazi".source = pkgs.callPackage ../../../pkgs/yazi/exifaudio.nix {};
      "yazi/plugins/ouch.yazi".source = pkgs.callPackage ../../../pkgs/yazi/ouch.nix {};
      "yazi/plugins/piper.yazi".source = pkgs.callPackage ../../../pkgs/yazi/piper.nix {};
      "yazi/plugins/relative-motions.yazi".source = pkgs.callPackage ../../../pkgs/yazi/relative-motions.nix {};
      "yazi/plugins/toggle-pane.yazi".source = pkgs.callPackage ../../../pkgs/yazi/toggle-pane.nix {};
    };

    programs.zsh.initContent =
      /*
      sh
      */
      ''
        function y() {
        	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        	yazi "$@" --cwd-file="$tmp"
        	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        		builtin cd -- "$cwd"
        	fi
        	rm -f -- "$tmp"
        }
      '';
  };
}
