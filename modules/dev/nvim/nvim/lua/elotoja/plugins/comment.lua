return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		-- import comment plugin safely
		local comment = require("Comment")

		-- fix https://github.com/JoosepAlviste/nvim-ts-context-commentstring/issues/82#issuecomment-2213944325
		require("ts_context_commentstring").setup({
			languages = {
				c = { __default = "// %s", __multiline = "/* %s */" },
			},
		})

		-- enable comment
		comment.setup({
			-- for commenting tsx, jsx, svelte, html files
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		})

		-- local comment_ft = require("Comment.ft")
		-- comment_ft.set("c", { "//%s" })
	end,
}
