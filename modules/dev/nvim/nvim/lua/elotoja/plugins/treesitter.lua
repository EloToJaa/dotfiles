return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
		{ "nushell/tree-sitter-nu", build = ":TSUpdate nu" },
	},
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"vim",
				"vimdoc",
				"c",
				"lua",
				"javascript",
				"typescript",
				"html",
				"zig",
				"go",
				"json",
				"bash",
				"yaml",
				"toml",
				"tsx",
				"svelte",
				"astro",
				"markdown",
				"markdown_inline",
				"dockerfile",
				"gitignore",
			},
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
