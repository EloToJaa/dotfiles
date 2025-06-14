{pkgs, ...}: {
  programs.nvf.settings.vim.extraPlugins = with pkgs.vimPlugins; {
    supermaven = {
      package = supermaven-nvim;
      setup =
        /*
        lua
        */
        ''
          require("supermaven-nvim").setup({
          	keymaps = {
          		accept_suggestion = "<C-Tab>",
          		clear_suggestion = "<C-]>",
          		accept_word = "<C-j>",
          	},
          	-- ignore_filetypes = { cpp = true },
          	color = {
          		suggestion_color = "#ffffff",
          		cterm = 244,
          	},
          	log_level = "info", -- set to "off" to disable logging completely
          	disable_inline_completion = false, -- disables inline completion for use with cmp
          	disable_keymaps = false, -- disables built in keymaps for more manual control
          	condition = function() return false end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
          })
        '';
    };
  };
}
