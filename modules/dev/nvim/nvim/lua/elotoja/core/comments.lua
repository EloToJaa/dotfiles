vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function() vim.bo.commentstring = "// %s" end,
})
