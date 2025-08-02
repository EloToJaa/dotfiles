{
  pkgs,
  lib,
  config,
  ...
}: let
  tmux-smart-launch = pkgs.writeShellScriptBin "tmux-smart-launch" (builtins.readFile ./tmux-smart-launch.sh);
in {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "ghostty";
    historyLimit = 10000;
    clock24 = true;
    baseIndex = 1;
    keyMode = "vi";
    escapeTime = 1000;
    secureSocket = true; # Check if has to be false for tmux-resurrect
    shortcut = "a";

    plugins = with pkgs.tmuxPlugins; [
      catppuccin
    ];

    extraConfigBeforePlugins = ''
      bind -n C-[ previous-window
      bind -n C-] next-window

      set-option -sa terminal-overrides ",xterm*:Tc"
    '';

    extraConfig = ''
      set -g @catppuccin_flavor 'mocha'
    '';
  };

  imports = [
    ./plugins
  ];

  programs.ghostty.settings.command = lib.mkIf config.programs.tmux.enable "${tmux-smart-launch}/bin/tmux-smart-launch";
}
