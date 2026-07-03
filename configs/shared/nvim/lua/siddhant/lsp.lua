vim.diagnostic.config({
    virtual_text = true, -- inline message after the line
    underline = true,
    update_in_insert = false,
    severity_sort = true,

    float = {
        border = "rounded",
        source = true,
    },

    signs = {
        text = {
            -- sign_text must be 1-2 display cells wide, else nvim throws Invalid 'sign_text'
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.HINT] = "H",
            [vim.diagnostic.severity.INFO] = "I",
        },
    },
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, {
                buffer = event.buf,
                desc = "LSP: " .. desc,
            })
        end

        map("gd", vim.lsp.buf.definition, "Goto definition")
        map("gD", vim.lsp.buf.declaration, "Goto declaration")
        map("gi", vim.lsp.buf.implementation, "Goto implementation")
        map("gr", vim.lsp.buf.references, "References")
        map("K", vim.lsp.buf.hover, "Hover docs")

        map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")

        map("<leader>e", vim.diagnostic.open_float, "Show line diagnostics")

        map("[d", function()
            vim.diagnostic.jump({ count = -1 })
        end, "Previous diagnostic")

        map("]d", function()
            vim.diagnostic.jump({ count = 1 })
        end, "Next diagnostic")
    end,
})

-- Go autoimports: run gopls' source.organizeImports code action before write,
-- independent of whether the goimports formatter is installed. General
-- formatting is owned by conform.nvim (which falls back to LSP when no Mason
-- formatter is available), so we do not register a generic LSP format-on-save.
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function(event)
        local clients = vim.lsp.get_clients({ bufnr = event.buf, name = "gopls" })
        local client = clients[1]
        if not client then
            return
        end

        local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
        params.context = { only = { "source.organizeImports" }, diagnostics = {} }

        local ok, result = pcall(
            vim.lsp.buf_request_sync,
            event.buf,
            "textDocument/codeAction",
            params,
            1000
        )
        if not ok or not result then
            return
        end

        for _, res in pairs(result) do
            for _, action in pairs(res.result or {}) do
                if action.edit then
                    pcall(vim.lsp.util.apply_workspace_edit, action.edit, client.offset_encoding)
                end
            end
        end
    end,
})
