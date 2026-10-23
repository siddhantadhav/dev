return {
    "saghen/blink.cmp",
    dependencies = {
        "rafamadriz/friendly-snippets",
    },

    -- release tag ships a prebuilt Rust fuzzy-matcher binary
    version = "1.*",

    opts = {
        -- CR accept
        -- C-j/C-k (or C-n/C-p or arrows) navigate
        -- C-space open
        -- C-e hide
        keymap = {
            preset = "default",
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            -- unbind the default C-y accept
            ["<C-y>"] = {},
        },

        appearance = {
            nerd_font_variant = "mono",
        },

        completion = {
            documentation = {
                auto_show = true,
            },
        },

        sources = {
            default = {
                "lsp",
                "path",
                "snippets",
                "buffer",
            },
        },

        fuzzy = {
            implementation = "prefer_rust_with_warning",
        },
    },

    opts_extend = {
        "sources.default",
    },

    config = function(_, opts)
        require("blink.cmp").setup(opts)
        -- Advertise blink's completion capabilities to every LSP server.
        vim.lsp.config("*", {
            capabilities = require("blink.cmp").get_lsp_capabilities(),
        })
    end,
}
