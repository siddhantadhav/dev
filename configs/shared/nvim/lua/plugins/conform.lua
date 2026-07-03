return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    -- Candidate formatters per filetype. Only those actually installed
    -- (via :Mason, found on PATH) run; the rest are skipped. Add/remove
    -- filetypes freely — an entry with no installed formatter is a no-op.
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "gofmt" },
    },
    -- Run only the first available formatter in each candidate list.
    stop_after_first = true,
    -- Fall back to LSP formatting when no Mason formatter is installed.
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 3000, lsp_format = "fallback" }
    end,
  },
}
