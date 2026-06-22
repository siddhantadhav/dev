vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then return end

    vim.treesitter.start(args.buf, lang)
  end,
})
