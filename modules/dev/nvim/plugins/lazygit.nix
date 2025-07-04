{
  programs.nixvim.plugins = {
    lazygit = {
      enable = true;
      settings.floating_window_border_chars = [];
    };
    lz-n.keymaps = [
      {
        key = "<leader>g";
        action = "<cmd>LazyGit<cr>";
        options.desc = "Open lazygit";
        plugin = "lazygit.nvim";
      }
    ];
  };
}
