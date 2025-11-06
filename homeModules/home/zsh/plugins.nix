{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.modules.home.zsh) plugins;
in {
  config = with pkgs.unstable;
    lib.mkIf plugins.enable {
      programs.zsh.plugins =
        (lib.optionals plugins.zsh-vi-mode.enable [
          # Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
          {
            name = "zsh-vi-mode";
            src = "${zsh-vi-mode}/share/zsh-vi-mode";
          }
        ])
        ++ (lib.optionals plugins.zsh-autopair.enable [
          {
            name = "autopair";
            file = "autopair.zsh";
            src = "${zsh-autopair}/share/zsh/zsh-autopair";
          }
        ])
        ++ (lib.optionals plugins.zsh-fzf-tab.enable [
          {
            name = "fzf-tab";
            src = "${zsh-fzf-tab}/share/fzf-tab";
          }
        ])
        ++ (lib.optionals plugins.zsh-auto-notify.enable [
          {
            name = "auto-notify";
            #file = "auto-notify.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "MichaelAquilina";
              repo = "zsh-auto-notify";
              rev = "b51c934d88868e56c1d55d0a2a36d559f21cb2ee";
              hash = "sha256-s3TBAsXOpmiXMAQkbaS5de0t0hNC1EzUUb0ZG+p9keE=";
            };
          }
        ])
        ++ (lib.optionals plugins.zsh-autosuggestions-abbreviations-strategy.enable [
          {
            name = "zsh-autosuggestions-abbreviations-strategy";
            file = "zsh-autosuggestions-abbreviations-strategy.plugin.zsh";
            src = "${zsh-autosuggestions-abbreviations-strategy}/share/zsh/site-functions";
          }
        ])
        ++ (lib.optionals plugins.zsh-system-clipboard.enable [
          {
            name = "zsh-system-clipboard";
            #file = "zsh-system-clipboard.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "kutsan";
              repo = "zsh-system-clipboard";
              rev = "5f1d497ee3c215a967c0e6b9a772e73c40332d52";
              hash = "sha256-dnWQEWa/Cxwopgj2teCpWhqX4Imx1PB7fHAa8djg8P4=";
            };
          }
        ])
        ++ (lib.optionals plugins.zsh-zhooks.enable [
          {
            name = "zhooks";
            file = "zhooks.plugin.zsh";
            src = "${zsh-zhooks}/share/zsh/zhooks";
          }
        ]);
    };
}
