{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) catppuccin;
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
  cfg = config.modules.home.tmux;
in {
  config = lib.mkIf cfg.enable {
    catppuccin.tmux = {
      inherit (catppuccin) flavor;
      enable = true;
      extraConfig = ''
        set -g @catppuccin_window_status_style "rounded"
        set -g status-right-length 100
        set -g status-left-length 100
        set -g status-left ""
        set -g status-right "#{E:@catppuccin_status_application}"
        set -agF status-right "#{E:@catppuccin_status_session}"

        set -g status-interval 5
      '';
    };
    programs.tmux.plugins = with pkgs.unstable.tmuxPlugins; [
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
  };
}
