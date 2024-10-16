{ pkgs, variables, ... }:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    catppuccin = {
      enable = true;
      flavor = "${variables.catppuccin.flavor}";
      extraConfig = ''
      set -g @catppuccin_window_status_style "rounded"
      set -g @catppuccin_window_number_position "right"

      set -g @catppuccin_window_default_fill "number"
      set -g @catppuccin_window_default_text "#W"

      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#W"

      set -g @catppuccin_status_left_separator  " <"
      set -g @catppuccin_status_right_separator ">"
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "no"

      set -g @catppuccin_directory_text "#{pane_current_path}"
      '';
    };
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
        set -g @resurrect-strategy-vim 'session'
        set -g @resurrect-strategy-nvim 'session'
        set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
        set -g @continuum-boot 'on'
        set -g @continuum-boot-options 'kitty'
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '10'
        '';
      }
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.yank
    ];
    extraConfig = ''
    set -g status-left ""
    set -g  status-right "#{E:@catppuccin_status_directory}"
    set -ag status-right "#{E:@catppuccin_status_user}"
    set -ag status-right "#{E:@catppuccin_status_host}"
    set -ag status-right "#{E:@catppuccin_status_session}"

    # base options
    set-option -sa terminal-overrides ",xterm*:Tc"
    set -g mouse on

    # base index
    set -g base-index 1
    set -g pane-base-index 1
    set-window-option -g pane-base-index 1
    set-option -g renumber-windows on

    # prefix
    unbind C-b
    set-option -g prefix C-a
    bind-key C-a send-prefix

    # window splitting
    bind-key v split-window -v -c "#{pane_current_path}"
    bind-key h split-window -h -c "#{pane_current_path}"

    # yank
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    # kill
    bind-key x kill-pane
    bind-key q kill-window

    # rename
    bind-key r command-prompt "rename-window '%%'"
    bind-key R command-prompt "rename-session '%%'"

    # reload config
    bind-key F source-file ~/.config/tmux/tmux.conf
    '';
  };
}
