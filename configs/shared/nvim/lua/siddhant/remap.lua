vim.g.mapleader = " "

vim.keymap.set("n", "<leader>ee", vim.cmd.Ex)
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set({ "v", "x" }, "<C-c>", '"+y')
vim.keymap.set("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })
