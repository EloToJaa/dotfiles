{
  config,
  lib,
  pkgs,
  ...
}: {
  # Source URLs were fetched via nurl
  programs.zsh.plugins = let
    omz = pkgs.fetchFromGitHub {
      owner = "ohmyzsh";
      repo = "ohmyzsh";
      rev = "95ef2516697aa764d1d4bb93ad3490584cc118ec";
      hash = "sha256-rjN+/5P/q7uXSVGf/jypOCYLvoGYGPMZTy1dL9+E4Uc=";
    };
  in
    with pkgs.unstable; [
      # Useful utilities
      {
        name = "you-should-use";
        #file = "you-should-use.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "56616de037082f7dc0a143eb244ea27e5a697ef9";
          hash = "sha256-XbTZpyUIpALsVezqnIfz7sV26hMi8z+2dW0mL2QbVIE=";
        };
      }
      {
        name = "omz-extract";
        file = "plugins/extract/extract.plugin.zsh";
        src = omz;
      }
      # Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
      {
        name = "zsh-vi-mode";
        src = "${zsh-vi-mode}/share/zsh-vi-mode";
      }

      # Fish-like Plugins
      {
        name = "autopair";
        #file = "autopair.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "449a7c3d095bc8f3d78cf37b9549f8bb4c383f3d";
          hash = "sha256-3zvOgIi+q7+sTXrT+r/4v98qjeiEL4Wh64rxBYnwJvQ=";
        };
      }
      {
        name = "zfunctions";
        #file = "zfunctions.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "mattmc3";
          repo = "zfunctions";
          rev = "f94ce963bbd1155321dc4ac8d3f9cb94b773d9ba";
          hash = "sha256-8yOX4NvD0CvlRKXX9yEoxrN/d7MMGuDdIqNn55revr0=";
        };
      }
      {
        name = "fzf-tab";
        src = "${zsh-fzf-tab}/share/fzf-tab";
      }
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
      {
        name = "zsh-autosuggestions-abbreviations-strategy";
        #file = "zsh-autosuggestions-abbreviations-strategy.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "olets";
          repo = "zsh-autosuggestions-abbreviations-strategy";
          rev = "8edbd1d52445d87172d355f8242082b1ec6c34e7";
          hash = "sha256-hYl9zplPpMoCsGmxX+NQtECZ5dHgQYqZfTGdV0vcZPk=";
        };
      }
      {
        name = "omz-sudo";
        file = "plugins/sudo/sudo.plugin.zsh";
        src = omz;
      }
      {
        name = "omz-fancy-ctrl-z";
        file = "plugins/fancy-ctrl-z/fancy-ctrl-z.plugin.zsh";
        src = omz;
      }

      # Tmux integration
      (lib.mkIf config.programs.tmux.enable {
        name = "omz-tmux";
        file = "plugins/tmux/tmux.plugin.zsh";
        src = omz;
      })
      # Make ZLE use system clipboard
      {
        name = "zsh-system-clipboard";
        #file = "zsh-system-clipboard.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "kutsan";
          repo = "zsh-system-clipboard";
          rev = "8b4229000d31e801e6458a3dfa2d60720c110d11";
          hash = "sha256-phsIdvuqcwtAVE1dtQyXcMgNdRMNY03/mIzsvHWPS1Y=";
        };
      }
      {
        name = "zhooks";
        #file = "zhooks.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = "zhooks";
          rev = "e6616b4a2786b45a56a2f591b79439836e678d22";
          hash = "sha256-zahXMPeJ8kb/UZd85RBcMbomB7HjfEKzQKjF2NnumhQ=";
        };
      }
    ];
}
