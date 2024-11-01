{
  pkgs,
  variables,
  ...
}: {
  home.packages = with pkgs; [
    exiftool
    jq
    ffmpeg
    ffmpegthumbnailer
    imagemagick
    poppler
    p7zip
  ];

  programs.yazi = {
    enable = true;
    #package = inputs.yazi.packages.${pkgs.system}.default;

    catppuccin = {
      enable = true;
      flavor = "${variables.catppuccin.flavor}";
    };

    #enableZshIntegration = true;
  };

  xdg.configFile."yazi/yazi.toml".source = ./yazi.toml;
  xdg.configFile."yazi/keymap.toml".source = ./keymap.toml;
}
