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

        -- Format on save, only if the attached server can format this buffer.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = event.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = event.buf, id = client.id })
                end,
            })
        end
    end,
})
