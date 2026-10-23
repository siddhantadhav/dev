-- Follow the ~/dev theme: ./dev theme renders theme/nvim.lua with the
-- colorscheme + accent. We watch that file, so ./dev theme recolours
-- already-open nvims too.
local file = vim.fn.expand("~/.config/dev/theme/nvim.lua")

local function apply()
  local ok, theme = pcall(dofile, file)
  if not ok then
    theme = { colorscheme = "catppuccin-mocha", mode = "dark", accent = "#cba6f7" }
  end
  vim.o.background = theme.mode
  if not pcall(vim.cmd.colorscheme, theme.colorscheme) then
    vim.cmd.colorscheme("habamax")
  end

  local hl = vim.api.nvim_set_hl
  -- the editor shows the terminal's glass through...
  hl(0, "Normal", { bg = "none" })
  hl(0, "FloatBorder", { bg = "none", fg = theme.accent })
  hl(0, "TelescopeBorder", { bg = "none", fg = theme.accent })
  hl(0, "CursorLineNr", { fg = theme.accent, bold = true })
  -- ...but floats and menus sit over code, so they get a solid backdrop
  if theme.bg_alt then
    hl(0, "NormalFloat", { bg = theme.bg_alt })
    hl(0, "Pmenu", { bg = theme.bg_alt, fg = theme.fg })
    hl(0, "PmenuSel", { bg = theme.surface, fg = theme.fg, bold = true })
  end
end

apply()

-- ./dev theme replaces the file (write + rename), so watch the directory
local watcher = vim.uv.new_fs_event()
if watcher then
  watcher:start(vim.fn.fnamemodify(file, ":h"), {}, function(_, name)
    if name == "nvim.lua" then
      vim.schedule(apply)
    end
  end)
end
