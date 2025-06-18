vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local keymap = vim.keymap

--keymap.set("n", "<leader>fv", vim.cmd.Ex, { desc = "File explorer" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>v", "<C-w>s", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>s", "<C-w>v", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>e", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>x", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>t", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>q", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>]", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>[", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>b", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

for i = 1, 9 do
	keymap.set("n", "<leader>" .. i, ":tabnext " .. i .. "<CR>", { desc = "Go to tab " .. i })
end
keymap.set("n", "<leader>0", ":tabnext 10<CR>", { desc = "Go to tab 10" })
