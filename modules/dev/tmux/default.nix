{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 10000;
    clock24 = true;
    baseIndex = 1;
    keyMode = "vi";
    escapeTime = 1000;
    secureSocket = true; # Check if has to be false for tmux-resurrect
    shortcut = "a";
  };
}
