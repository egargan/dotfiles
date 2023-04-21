return {
    {
        -- Plugin dev-oriented tree sitter library
        'windwp/nvim-ts-autotag',
        config = true,
        event = { "BufReadPre", "BufNewFile" },
    },

    {
        -- Code commenting plugin
        'numToStr/Comment.nvim',
        event = { "BufReadPre", "BufNewFile" },
        config = true,
    },

    {
        -- Easy surrounding quotes, tags, parens, etc.
        'tpope/vim-surround',
        event = { "BufReadPre", "BufNewFile" },
    },

    {
        -- Easy surrounding quotes, tags, parens, etc.
        'junegunn/vim-easy-align',
        keys = {
            {
                'ga',
                mode = { 'x', 'n' },
                function() vim.cmd('EasyAlign') end,
                desc = "Easy align text"
            },
        }
    },

    {
        'zbirenbaum/copilot.lua',
        cmd = "Copilot",
        event = { "InsertEnter" },
        config = function()
            require("copilot").setup({
                panel = {
                    enabled = true,
                    auto_refresh = true,
                    keymap = {
                        jump_prev = "[c",
                        jump_next = "]c",
                        accept = "<CR>",
                        open = "<C-c>"
                    },
                    layout = {
                        position = "bottom", -- | top | left | right
                        ratio = 0.3
                    },
                },
            })
        end,
    }
}
