return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>df", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>ds", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "<leader>d[", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "<leader>d]", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		local flake = os.getenv("NH_FLAKE")
		local handle = io.popen("hostname")

		local hostname
		if handle then
			hostname = handle:read("*a")
			handle:close()
		else
			hostname = "desktop"
		end
		hostname = hostname:gsub("^%s*(.-)%s*$", "%1")

		vim.lsp.enable("nixd")
		vim.lsp.config("nixd", {
			cmd = { "nixd" },
			settings = {
				nixd = {
					nixpkgs = {
						expr = 'import (builtins.getFlake "' .. flake .. '").inputs.nixpkgs { }',
					},
					formatting = {
						command = { "alejandra" },
					},
					options = {
						nixos = {
							expr = '(builtins.getFlake "' .. flake .. '").nixosConfigurations.' .. hostname .. ".options",
						},
					},
				},
			},
		})

		vim.lsp.enable("clangd")
		vim.lsp.config("clangd", {
			capabilities = capabilities,
		})

		vim.lsp.enable("ruff")
		vim.lsp.config("ruff", {
			capabilities = capabilities,
			init_options = {
				settings = {
					organizeImports = true,
				},
			},
		})

		vim.lsp.enable("elixirls")
		vim.lsp.config("elixirls", {
			capabilities = capabilities,
			cmd = { "elixir-ls" },
		})

		vim.lsp.enable("rust_analyzer")
		vim.lsp.config("rust_analyzer", {
			capabilities = capabilities,
			on_attach = function(client, bufnr) vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end,
			settings = {
				["rust-analyzer"] = {
					imports = {
						granularity = {
							group = "module",
						},
						prefix = "self",
					},
					cargo = {
						allFeatures = true,
						buildScripts = {
							enable = true,
						},
					},
					checkOnSave = {
						command = "clippy",
					},
					procMacro = {
						enable = true,
					},
				},
			},
		})

		vim.lsp.enable("gopls")
		vim.lsp.config("gopls", {
			capabilities = capabilities,
			settings = {
				analyses = {
					unusedparams = true,
				},
				staticcheck = true,
				gofumpt = true,
			},
		})

		vim.lsp.enable("svelte")
		vim.lsp.config("svelte", {
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx) client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match }) end,
				})
			end,
		})

		vim.lsp.enable("emmet_ls")
		vim.lsp.config("emmet_ls", {
			capabilities = capabilities,
			filetypes = {
				"html",
				"typescriptreact",
				"javascriptreact",
				"css",
				"sass",
				"scss",
				"less",
				"svelte",
			},
		})

		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})

		vim.lsp.enable("pyright")
		vim.lsp.config("pyright", {
			capabilities = capabilities,
			pyright = {
				disableOrganizeImports = true,
			},
			python = {
				analysis = {
					ignore = { "*" },
				},
			},
		})

		vim.lsp.enable("bash_ls")
		vim.lsp.config("bash_ls", {
			cmd = { "bash-language-server", "start" },
			filetypes = { "bash", "sh" },
		})

		-- vim.lsp.confg("templ", {
		-- 	capabilities = capabilities,
		-- 	on_attach = function(client, bufnr)
		-- 		vim.api.nvim_create_autocmd({ "BufWritePre" }, { pattern = { "*.templ" }, callback = vim.lsp.buf.format })
		-- 	end,
		-- })

		vim.lsp.enable("zls")
		vim.lsp.enable("astro")
		vim.lsp.enable("tailwindcss")
		vim.lsp.enable("ts_ls")
		vim.lsp.enable("lua_ls")
		vim.lsp.enable("docker_compose_language_service")
		vim.lsp.enable("sqls")
		vim.lsp.enable("taplo")
		vim.lsp.enable("yamlls")
		vim.lsp.enable("jsonls")
		vim.lsp.enable("html")
		vim.lsp.enable("cssls")
	end,
}
