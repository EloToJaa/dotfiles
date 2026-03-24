{
  pkgs,
  lib,
  config,
  settings,
  ...
}: let
  tmux-smart-launch = pkgs.writeShellScriptBin "tmux-smart-launch" (builtins.readFile ./tmux-smart-launch.sh);
  cfg = config.modules.home.tmux;
  inherit (settings) isServer;
in {
  config = lib.mkIf cfg.enable {
    programs = {
      tmux = {
        enable = true;
        package = pkgs.unstable.tmux;
        shell = "${config.programs.zsh.package}/bin/zsh";
        terminal =
          if isServer
          then "xterm-256color"
          else "ghostty";
        historyLimit = 10000;
        clock24 = true;
        baseIndex = 1;
        keyMode = "vi";
        escapeTime = 0;
        secureSocket = false;
        shortcut = "a";
        newSession = true;

        extraConfig = ''
          set-option -sa terminal-overrides ",xterm*:Tc"
          set -g detach-on-destroy off
          set -g mouse on
          set -g renumber-windows on
          set -g set-clipboard on

          set -g status-style bg=default
          set -g window-status-current-style bg=default
          set -g window-status-style bg=default

          set -g pane-active-border-style 'fg=blue,bg=default'
          set -g pane-border-style 'fg=brightblack,bg=default'

          set -g extended-keys on
          set -as terminal-features 'xterm*:extkeys'

          bind-key [ previous-window
          bind-key ] next-window
          bind-key -n C-[ previous-window
          bind-key -n C-] next-window

          bind-key x kill-pane
          bind-key q kill-window

          bind-key v split-window -v -c "#{pane_current_path}"
          bind-key s split-window -h -c "#{pane_current_path}"
          bind-key t new-window

          # Pass on Ctrl+Tab and Ctrl+Shift+Tab
          bind-key -n C-Tab send-keys Escape [27\;5\;9~
          bind-key -n C-S-Tab send-keys Escape [27\;6\;9~

          # unbind-key ,
          bind-key r command-prompt -I "#W" { rename-window "%%" }
          bind-key R source-file ~/.config/tmux/tmux.conf

          bind-key L run-shell "workmux last-done"
          bind-key Tab run-shell "workmux last-agent"

          setw -g aggressive-resize on
        '';
      };

      fzf.tmux.enableShellIntegration = true;
      # ghostty.settings.command = lib.mkIf config.programs.tmux.enable "${tmux-smart-launch}/bin/tmux-smart-launch";
    };
  };
}
