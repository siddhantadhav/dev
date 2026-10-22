-- Every family ~/dev/themes can pick; siddhant/theme.lua chooses which one
-- via :colorscheme, which makes lazy.nvim load the matching plugin.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      transparent_background = true,
      integrations = {
        blink_cmp = true,
        harpoon = true,
        mason = true,
        nvimtree = true,
        telescope = { enabled = true },
        treesitter = true,
      },
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = {
      disable_background = true,
      styles = { transparency = true },
      enable = {
        terminal = true,
        legacy_highlights = true,
        migrations = true,
      },
    },
  },
}
