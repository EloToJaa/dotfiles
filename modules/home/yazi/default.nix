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
  ];
  programs.yazi = {
    enable = true;
    #package = inputs.yazi.packages.${pkgs.system}.default;

    catppuccin = {
      enable = true;
      flavor = "${variables.catppuccin.flavor}";
    };

    enableZshIntegration = true;
  };
}
