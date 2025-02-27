vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function()
		print("Autocmd test")
		vim.opt.commentstring = "// %s"
	end,
})
