{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    ANDROID_HOME = "${config.home.homeDirectory}/Android/Sdk";
    SHELL = "${pkgs.zsh}/bin/zsh";
  };
}
