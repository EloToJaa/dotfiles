return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
	opts = {
		focus = true,
		auto_open = true,
		auto_close = true,
		use_diagnostic_signs = true,
		-- Set up autocommand for wrapping in Trouble buffers
		setup = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "Trouble",
				callback = function()
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true -- Avoid breaking words in the middle
					vim.opt_local.breakindent = true
				end,
			})
		end,
	},
	cmd = "Trouble",
	keys = {
		{
			"<leader>xw",
			"<cmd>Trouble diagnostics toggle<CR>",
			desc = "Open trouble workspace diagnostics",
		},
		{
			"<leader>xd",
			"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
			desc = "Open trouble document diagnostics",
		},
		{ "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
		{ "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Open trouble location list" },
		{ "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "Open todos in trouble" },
	},
}
