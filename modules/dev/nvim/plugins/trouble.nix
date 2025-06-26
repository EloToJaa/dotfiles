{
  programs.nixvim.plugins = {
    trouble = {
      enable = true;
      settings.focus = true;
    };
    lz-n.keymaps = [
      {
        action = "<cmd>Trouble diagnostics toggle<CR>";
        key = "<leader>dw";
        options.desc = "Open trouble workspace diagnostics";
        plugin = "trouble.nvim";
      }
      {
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
        key = "<leader>dd";
        options.desc = "Open trouble document diagnostics";
        plugin = "trouble.nvim";
      }
      {
        action = "<cmd>Trouble quickfix toggle<CR>";
        key = "<leader>dq";
        options.desc = "Open trouble quickfix list";
        plugin = "trouble.nvim";
      }
      {
        action = "<cmd>Trouble loclist toggle<CR>";
        key = "<leader>dl";
        options.desc = "Open trouble location list";
        plugin = "trouble.nvim";
      }
      {
        action = "<cmd>Trouble todo toggle<CR>";
        key = "<leader>dt";
        options.desc = "Open todos in trouble";
        plugin = "trouble.nvim";
      }
    ];
  };
}
