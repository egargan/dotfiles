return {
    {
        -- Plugin dev-oriented tree sitter library
        'windwp/nvim-ts-autotag',
        config = true,
        event = { "BufReadPre", "BufNewFile" },
    },

    {
        -- Code commenting plugin
        'tpope/vim-commentary',
        event = { "BufReadPre", "BufNewFile" },
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
    }
}
