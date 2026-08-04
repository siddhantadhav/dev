vim.g.mapleader = " "

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("t", "jk", "<C-\\><C-n>")
vim.keymap.set({ "v", "x" }, "<C-c>", '"+y')

vim.keymap.set("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

vim.keymap.set("n", "<leader>|", ":vsplit<CR>", { desc = "Split window" })
vim.keymap.set("n", "<leader>-", ":split<CR>", { desc = "Split window" })

vim.keymap.set("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })

vim.keymap.set("n", "<leader>tt", ":belowright split | terminal<CR>", { desc = "Open terminal in split below" })

local session_dir = vim.fn.stdpath("data") .. "/sessions"

vim.keymap.set("n", "<leader>ws", function()
    vim.fn.mkdir(session_dir, "p")
    local default = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    vim.ui.input({ prompt = "Session name: ", default = default }, function(name)
        if name == nil then
            return -- cancelled
        end
        if name == "" then
            name = default
        end
        local file = session_dir .. "/" .. name .. ".vim"
        vim.cmd("mksession! " .. vim.fn.fnameescape(file))
        vim.notify("Session saved: " .. name)
    end)
end, { desc = "Save session" })

vim.keymap.set("n", "<leader>wl", function()
    require("telescope.builtin").find_files({
        prompt_title = "Sessions",
        cwd = session_dir,
        attach_mappings = function(prompt_bufnr)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if entry then
                    local file = entry.path or (session_dir .. "/" .. entry.value)
                    vim.cmd("source " .. vim.fn.fnameescape(file))
                end
            end)
            return true
        end,
    })
end, { desc = "List sessions" })
