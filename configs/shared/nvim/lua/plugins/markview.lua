return {
  "OXY2DEV/markview.nvim",
  lazy = false, -- markview handles its own lazy-loading; don't defer it
  priority = 49,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- optional, for icons
  },
  opts = {
    preview = {
      filetypes = { "markdown", "quarto", "rmd" },
      icon_provider = "devicons", -- or "internal" / "mini"
    },
    markdown_inline = {
      inline_codes = { padding_left = "", padding_right = "" },
      hyperlinks = {
        default = { icon = "" }, -- no icon before links (fixes table drift)
      },
    },
  },
  keys = {
    { "<leader>mt", "<cmd>Markview<cr>",             desc = "Markview toggle" },
    { "<leader>ms", "<cmd>Markview splitToggle<cr>", desc = "Markview split" },
    { "<leader>mw", "<cmd>set wrap!<cr>",            desc = "Toggle wrap" },
  },
}
