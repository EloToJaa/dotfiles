{pkgs, ...}: {
  programs.tmux.plugins = [
    {
      plugin = pkgs.tmuxPlugins.mkTmuxPlugin {
        name = "smart-splits";
        version = "unstable-2025-08-02";
        src = pkgs.fetchFromGitHub {
          owner = "mrjones2014";
          repo = "smart-splits.nvim";
          rev = "f46b79cf9e83b0a13a4e3f83e3bd5b0d2f172bf2";
          hash = "sha256-DHc26iiaNIMod1r2P0wKhpUI1TtjtnU+ZqOFlkdseVE=";
        };
      };
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
}
