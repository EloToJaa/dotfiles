require("catppuccin").setup({
  flavour = "auto", -- latte, frappe, macchiato, mocha
  background = {    -- :h background
    light = "latte",
    dark = "mocha",
  },
  transparent_background = true,
})

vim.cmd.colorscheme "catppuccin"

return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 }
}
