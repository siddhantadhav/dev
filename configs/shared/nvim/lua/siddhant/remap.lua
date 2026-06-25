vim.g.mapleader = " "

vim.keymap.set("n", "<leader>ee", vim.cmd.Ex)
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set({ "v", "x" }, "<C-c>", '"+y')
