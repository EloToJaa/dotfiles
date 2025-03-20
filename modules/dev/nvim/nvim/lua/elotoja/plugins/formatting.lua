return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettierd", "prettier" },
				typescript = { "prettierd", "prettier" },
				javascriptreact = { "prettierd", "prettier" },
				typescriptreact = { "prettierd", "prettier" },
				svelte = { "prettierd", "prettier" },
				astro = { "prettierd", "prettier" },
				css = { "prettierd", "prettier" },
				html = { "prettierd", "prettier" },
				json = { "prettierd", "prettier" },
				yaml = { "prettierd", "prettier" },
				markdown = { "prettierd", "prettier" },
				graphql = { "prettierd", "prettier" },
				liquid = { "prettierd", "prettier" },
				lua = { "stylua" },
				nix = { "alejandra" },
				rust = { "rustfmt" },
				sql = { "sqlfmt" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				go = { "gofumpt" },
				python = { "ruff_organize_imports" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
			formatters = {
				ruff_organize_imports = {
					command = "ruff",
					args = {
						"check",
						"--force-exclude",
						"--select=I001",
						"--fix",
						"--exit-zero",
						"--stdin-filename",
						"$FILENAME",
						"-",
					},
					stdin = true,
					cwd = require("conform.util").root_file({
						"pyproject.toml",
						"ruff.toml",
						".ruff.toml",
					}),
				},
			},
		})

		vim.keymap.set(
			{ "n", "v" },
			"<leader>mp",
			function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 4000,
				})
			end,
			{ desc = "Format file or range (in visual mode)" }
		)
	end,
}
