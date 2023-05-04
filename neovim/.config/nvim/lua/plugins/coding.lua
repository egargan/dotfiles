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
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 100,
                    keymap = {
                        accept = "<C-l>",
                        accept_word = false,
                        accept_line = false,
                        next = "<C-k>",
                        prev = "<C-j>",
                        dismiss = "<C-h>",
                    },
                },
            })
        end,
    }
}
