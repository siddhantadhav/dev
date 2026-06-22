return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',        -- the new rewrite; required for 0.12
  lazy = false,
  build = ':TSUpdate',    -- recompiles parsers when the plugin updates
  config = function()
    require('nvim-treesitter').setup()

    require('nvim-treesitter').install({
      'lua', 'vim', 'vimdoc', 'query',
      'python', 'javascript', 'typescript', 'tsx',
      'json', 'yaml', 'toml', 'markdown', 'markdown_inline',
      'bash', 'c', 'rust', 'go', 'html', 'css',
    })

    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
