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

  xdg.configFile = {
    "yazi/yazi.toml".source = ./yazi.toml;
    "yazi/keymap.toml".source = ./keymap.toml;
    "yazi/theme.toml".source = ./theme.toml;
    "yazi/Catppuccin-mocha.tmTheme".source = ./theme.tmTheme;
  };
}
