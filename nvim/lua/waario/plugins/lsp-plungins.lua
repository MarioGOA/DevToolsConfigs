return {
    { 
        "rafamadriz/friendly-snippets" 
    },
    {
        'saghen/blink.cmp',
        dependencies = { 'rafamadriz/friendly-snippets' },
        version = '1.*',
        opts = {
            keymap = {
                preset = 'default',
                ['<S-Tab>'] = { 'select_prev', 'fallback' },
                ['<Tab>'] = { 'select_next', 'fallback' },
                ['<C-e>'] = { 'hide', 'fallback' },
                ['<CR>'] = { 'accept', 'fallback' },
            },

            appearance = {
                nerd_font_variant = 'mono'
            },

            completion = { documentation = { auto_show = true, auto_show_delay_ms = 500, } },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },

            fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" }
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" }
    },
    {
        "mason-org/mason.nvim",
        opts = {}
    },
    -- Linter for Checkstyle
    {
        "mfussenegger/nvim-lint"
    },
    -- JAVA LSP
    {
        "mfussenegger/nvim-jdtls"
    }
}
