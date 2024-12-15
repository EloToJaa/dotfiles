{pkgs, ...}: {
  home.packages = with pkgs; [
    exiftool
    jq
    ffmpeg
    ffmpegthumbnailer
    imagemagick
    poppler
    p7zip
    yazi
  ];

  programs.zsh.initExtra = ''
    function y() {
    	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    	yazi "$@" --cwd-file="$tmp"
    	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    		builtin cd -- "$cwd"
    	fi
    	rm -f -- "$tmp"
    }
  '';

  xdg.configFile = {
    "yazi/yazi.toml".source = ./yazi.toml;
    "yazi/keymap.toml".source = ./keymap.toml;
    "yazi/theme.toml".source = ./theme.toml;
    "yazi/Catppuccin-mocha.tmTheme".source = ./theme.tmTheme;
    "yazi/init.lua".source = ./init.lua;
    "yazi/plugins/symlink.yazi/init.lua".source = ./plugins/symlink.lua;
  };
}
