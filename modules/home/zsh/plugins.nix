{pkgs, ...}: {
  programs.zsh.plugins = with pkgs.unstable; [
    # Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
    {
      name = "zsh-vi-mode";
      src = "${zsh-vi-mode}/share/zsh-vi-mode";
    }

    # Fish-like Plugins
    {
      name = "autopair";
      file = "autopair.zsh";
      src = "${zsh-autopair}/share/zsh/zsh-autopair";
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
      file = "zsh-autosuggestions-abbreviations-strategy.plugin.zsh";
      src = "${zsh-autosuggestions-abbreviations-strategy}/share/zsh/site-functions";
    }

    # Make ZLE use system clipboard
    # {
    #   name = "zsh-system-clipboard";
    #   file = "zsh-system-clipboard.zsh";
    #   src = "${zsh-system-clipboard}/share/zsh/zsh-system-clipboard";
    # }
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
      file = "zhooks.plugin.zsh";
      src = "${zsh-zhooks}/share/zsh/zhooks";
    }
  ];
}
