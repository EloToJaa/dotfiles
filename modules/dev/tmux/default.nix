{
  pkgs,
  lib,
  config,
  ...
}: let
  tmux-smart-launch = pkgs.writeShellScriptBin "tmux-smart-launch" (builtins.readFile ./tmux-smart-launch.sh);
  smart-splits = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "smart-splits";
    rtpFilePath = "smart-splits";
    version = "unstable-2025-08-02";
    src = pkgs.fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "f46b79cf9e83b0a13a4e3f83e3bd5b0d2f172bf2";
      hash = "sha256-DHc26iiaNIMod1r2P0wKhpUI1TtjtnU+ZqOFlkdseVE=";
    };
  };
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
    newSession = true;

    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      yank
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

          set -g @smart-splits_resize_step_size '3' # change the step-size for resizing.
        '';
      }
    ];

    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g mouse on

      bind -n C-[ previous-window
      bind -n C-] next-window

      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"

      set -g @catppuccin_flavor 'mocha'

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };

  programs.ghostty.settings.command = lib.mkIf config.programs.tmux.enable "${tmux-smart-launch}/bin/tmux-smart-launch";
}
