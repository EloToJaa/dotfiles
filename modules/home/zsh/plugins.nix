{
  config,
  lib,
  pkgs,
  ...
}: {
  # Source URLs were fetched via nurl
  programs.zsh.plugins = with pkgs.unstable; let
    omz = oh-my-zsh;
  in [
    # Useful utilities
    {
      name = "you-should-use";
      file = "you-should-use.plugin.zsh";
      src = "${zsh-you-should-use}/share/zsh/plugins/you-should-use";
    }
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
      file = "zsh-system-clipboard.zsh";
      src = "${zsh-system-clipboard}/share/zsh/zsh-system-clipboard";
    }
    {
      name = "zhooks";
      file = "zhooks.plugin.zsh";
      src = "${zsh-hooks}/share/zsh/zhooks";
    }
  ];
}
