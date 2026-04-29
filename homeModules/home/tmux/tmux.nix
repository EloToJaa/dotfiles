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
          set-option -sa terminal-overrides ",xterm*:Tc,ghostty:Tc"
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
          set -as terminal-features 'xterm*:extkeys,ghostty:extkeys'

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

          bind-key m display-popup -h 85% -w 80% -E "btop"
          bind-key g display-popup -h 85% -w 80% -d "#{pane_current_path}" -E "lazygit"
          bind-key a display-popup -h 85% -w 80% -E "workmux dashboard"
          bind-key h display-popup -h 85% -w 80% -E "gh dash"
          bind-key L run-shell "workmux last-done"
          bind-key Tab run-shell "workmux last-agent"
          bind-key b run-shell "workmux sidebar"

          # Alt+j / Alt+k to cycle agents (no prefix needed)
          bind -n M-j run-shell "workmux sidebar next"
          bind -n M-k run-shell "workmux sidebar prev"

          # Alt+1..9 to jump directly
          bind -n M-1 run-shell "workmux sidebar jump 1"
          bind -n M-2 run-shell "workmux sidebar jump 2"
          bind -n M-3 run-shell "workmux sidebar jump 3"
          bind -n M-4 run-shell "workmux sidebar jump 4"
          bind -n M-5 run-shell "workmux sidebar jump 5"
          bind -n M-6 run-shell "workmux sidebar jump 6"
          bind -n M-7 run-shell "workmux sidebar jump 7"
          bind -n M-8 run-shell "workmux sidebar jump 8"
          bind -n M-9 run-shell "workmux sidebar jump 9"
          bind -n M-0 run-shell "workmux sidebar jump 10"

          setw -g aggressive-resize on
          set -g automatic-rename off
        '';
      };

      fzf.tmux.enableShellIntegration = true;
      # ghostty.settings.command = lib.mkIf config.programs.tmux.enable "${tmux-smart-launch}/bin/tmux-smart-launch";
    };
  };
}
