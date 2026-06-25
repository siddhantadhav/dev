-- TODO: set options
vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true -- relative line number
opt.number = true         -- line number

-- tabs and indentation
opt.tabstop = 2       -- 2 spaces for tabs
opt.shiftwidth = 2    -- 2 spaces for indent width
opt.expandtab = true  -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false      -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true  -- if included mixed case, then it assumes it is case sensitive

opt.backspace = "indent,eol,start"

opt.splitright = true
opt.splitbelow = true

opt.autoread = true
