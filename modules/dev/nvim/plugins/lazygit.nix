{
  programs.nixvim.plugins = {
    lazygit = {
      enable = true;
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
