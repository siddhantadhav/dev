return {
  "rose-pine/neovim",
  name = "rose-pine",
  config = function()
    require("rose-pine").setup({
      variant = "auto",
      dark_variant = "main",

      disable_background = true, -- correct place if you want it

      styles = {
        transparency = true,
      },

      enable = {
        terminal = true,
        legacy_highlights = true,
        migrations = true,
      },
    })

    vim.cmd("colorscheme rose-pine")
  end,
}
