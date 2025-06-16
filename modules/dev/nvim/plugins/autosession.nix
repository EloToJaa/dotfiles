{pkgs, ...}: {
  programs.nvf.settings.vim.extraPlugins = with pkgs.vimPlugins; {
    auto-session = {
      package = auto-session;
      setup =
        /*
        lua
        */
        ''
          require("auto-session").setup({
          	auto_restore_enabled = true,
          	auto_session_suppress_dirs = { "~/", "~/Downloads", "~/Documents", "~/Desktop/" },
          })

          local keymap = vim.keymap

          keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
          keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
          keymap.set("n", "<leader>wf", "<cmd>SessionSearch<CR>", { desc = "Search for session" }) -- search for session
        '';
    };
  };
}
