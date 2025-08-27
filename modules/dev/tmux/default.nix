{
  pkgs,
  lib,
  config,
  ...
}: let
  tmux-smart-launch = pkgs.writeShellScriptBin "tmux-smart-launch" (builtins.readFile ./tmux-smart-launch.sh);
  smart-splits = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "smart-splits";
    rtpFilePath = "smart-splits.tmux";
    version = "unstable-2025-08-02";
    src = pkgs.fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "f46b79cf9e83b0a13a4e3f83e3bd5b0d2f172bf2";
      hash = "sha256-DHc26iiaNIMod1r2P0wKhpUI1TtjtnU+ZqOFlkdseVE=";
    };
  };
in {
  programs = {
    tmux = {
      enable = true;
      package = pkgs.unstable.tmux;
      shell = "${pkgs.unstable.zsh}/bin/zsh";
      terminal = "ghostty";
      historyLimit = 10000;
      clock24 = true;
      baseIndex = 1;
      keyMode = "vi";
      escapeTime = 0;
      secureSocket = false; # Check if has to be false for tmux-resurrect
      shortcut = "a";
      newSession = true;

      plugins = with pkgs.unstable.tmuxPlugins; [
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g status-position top
            set -g pane-active-border-style 'fg=magenta,bg=default'
            set -g pane-border-style 'fg=brightblack,bg=default'
            set -g @catppuccin_flavor 'mocha'

            set -g @catppuccin_window_status_style "rounded"
            set -g status-right-length 100
            set -g status-left-length 100
            set -g status-left ""
            set -g status-right "#{E:@catppuccin_status_application}"
            set -agF status-right "#{E:@catppuccin_status_session}"

            set -g status-interval 5

            set -g status-style bg=default
          '';
        }
        {
          plugin = yank;
          extraConfig = ''
            bind-key c copy-mode
            bind-key p paste-buffer -p

            bind-key -T copy-mode-vi v send-keys -X begin-selection
            bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
            bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
          '';
        }
        resurrect
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
          '';
        }
        {
          plugin = smart-splits;
          extraConfig = ''
            set -g @smart-splits_move_left_key  'C-h' # key-mapping for navigation.
            set -g @smart-splits_move_down_key  'C-j' #  --"--
            set -g @smart-splits_move_up_key    'C-k' #  --"--
            set -g @smart-splits_move_right_key 'C-l' #  --"--

            set -g @smart-splits_resize_left_key  'M-h' # key-mapping for resizing.
            set -g @smart-splits_resize_down_key  'M-j' #  --"--
            set -g @smart-splits_resize_up_key    'M-k' #  --"--
            set -g @smart-splits_resize_right_key 'M-l' #  --"--

            set -g @smart-splits_resize_step_size '1' # change the step-size for resizing.
          '';
        }
        {
          plugin = fzf-tmux-url;
          extraConfig = ''
            set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
            set -g @fzf-url-history-limit '2000'
          '';
        }
      ];

      extraConfig = ''
        set-option -sa terminal-overrides ",xterm*:Tc"
        set -g detach-on-destroy off
        set -g mouse on
        set -g renumber-windows on
        set -g set-clipboard on

        # bind-key -r B run-shell "~/.config/tmux/scripts/sessionizer.sh ~/Projects/dotfiles"

        bind-key [ previous-window
        bind-key ] next-window
        bind-key -n C-[ previous-window
        bind-key -n C-] next-window
        # bind-key -n M-[ swap-window -t -1 # breaks yazi with nvim open
        # bind-key -n M-] next-window -t 1 # breaks yazi with nvim open

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

        setw -g aggressive-resize on
      '';
    };

    fzf.tmux.enableShellIntegration = true;
    ghostty.settings.command = lib.mkIf config.programs.tmux.enable "${tmux-smart-launch}/bin/tmux-smart-launch";
  };
}
