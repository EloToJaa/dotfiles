{
  pkgs,
  lib,
  config,
  ...
}: let
  tmux-smart-launch = pkgs.writeShellScriptBin "tmux-smart-launch" (builtins.readFile ./tmux-smart-launch.sh);
in {
  imports = [
    ./plugins
  ];

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
    newSession = true;

    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      yank
    ];

    extraConfigBeforePlugins = ''
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g mouse on

      bind -n C-[ previous-window
      bind -n C-] next-window

      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
    '';

    extraConfig = ''
      set -g @catppuccin_flavor 'mocha'

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };

  programs.ghostty.settings.command = lib.mkIf config.programs.tmux.enable "${tmux-smart-launch}/bin/tmux-smart-launch";
}
