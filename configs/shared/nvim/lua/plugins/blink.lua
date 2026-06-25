return {
    "saghen/blink.cmp",
    dependencies = {
        "rafamadriz/friendly-snippets",
    },

    -- release tag ships a prebuilt Rust fuzzy-matcher binary
    version = "1.*",

    opts = {
        -- C-y accept
        -- C-n/C-p or arrows navigate
        -- C-space open
        -- C-e hide
        -- C-k signature
        keymap = {
            preset = "default",
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
}
