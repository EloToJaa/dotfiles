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
      "yazi/Catppuccin-mocha.tmTheme".source = pkgs.yazi-theme-bat;
      "yazi/theme.toml".source = pkgs.yazi-theme-yazi;

      # Plugins
      "yazi/plugins/git.yazi".source = pkgs.yazi-git;
      "yazi/plugins/smart-filter.yazi".source = pkgs.yazi-smart-filter;
      "yazi/plugins/smart-enter.yazi".source = pkgs.yazi-smart-enter;
      "yazi/plugins/mount.yazi".source = pkgs.yazi-mount;
      "yazi/plugins/chmod.yazi".source = pkgs.yazi-chmod;
      "yazi/plugins/diff.yazi".source = pkgs.yazi-diff;
      "yazi/plugins/copy-file-contents.yazi".source = pkgs.yazi-copy-file-contents;
      "yazi/plugins/system-clipboard.yazi".source = pkgs.yazi-system-clipboard;
      "yazi/plugins/exifaudio.yazi".source = pkgs.yazi-exifaudio;
      "yazi/plugins/ouch.yazi".source = pkgs.yazi-ouch;
      "yazi/plugins/piper.yazi".source = pkgs.yazi-piper;
      "yazi/plugins/relative-motions.yazi".source = pkgs.yazi-relative-motions;
      "yazi/plugins/toggle-pane.yazi".source = pkgs.yazi-toggle-pane;
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
