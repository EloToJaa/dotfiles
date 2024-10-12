{ pkgs, variables, ... }:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
        set -g @catppuccin_flavour '${variables.catppuccin.flavor}'
        set -g @catppuccin_window_tabs_enabled on
        set -g @catppuccin_date_time "%H:%M"
        set -g @catppuccin_window_status_style "rounded"
        set -g @catppuccin_window_default_text "#W"
        set -g @catppuccin_window_current_text "#W"
        '';
      }
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.yank
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
        set -g @continuum-restore 'on'
        set -g @continuum-boot 'on'
        set -g @continuum-save-interval '10'
        '';
      }
    ];
    extraConfig = ''
    #base options
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
    bind-key f source-file ~/.config/tmux/tmux.conf
    '';
  };
}
