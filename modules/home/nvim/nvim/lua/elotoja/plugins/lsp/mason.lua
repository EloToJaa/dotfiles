return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"emmet_ls",
				"pyright",
				"zls",
				"gopls",
				-- "clangd", -- replaced by clang-tools from nixpkgs
				"taplo",
				"astro",
				"rust_analyzer",
				"bashls",
				"docker_compose_language_service",
				"htmx",
				"sqls",
				"templ",
				"elixirls",
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier",
				"prettierd",
				"stylua",
				"isort",
				"black",
				"clang-format",
				"shfmt",
				"pylint",
				"eslint_d",
				"cpplint",
				"sqlfluff",
				"sqlfmt",
				"gofumpt",
			},
		})
	end,
}
