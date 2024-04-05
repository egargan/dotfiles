return {
  {
    -- Show git diff UI in gutter
    'lewis6991/gitsigns.nvim',
    event = "VeryLazy",
    opts = {
      current_line_blame_opts = {
        delay = 500,
      },
      preview_config = {
        row = 1,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- Navigation
        vim.keymap.set('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr })

        vim.keymap.set('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr })

        -- Actions
        vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', { buffer = bufnr })
        vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { buffer = bufnr })
        vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hb', function() gs.blame_line { full = true } end, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr })

        -- Text object
        vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { buffer = bufnr })
      end
    },
  },

  {
    -- Indentation indicators
    'lukas-reineke/indent-blankline.nvim',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('ibl').setup({
        indent = {
          char = '│',
        },
        scope = {
          enabled = true,
          show_start = false,
          highlight = { "@keyword", "@label", "@function" },
        }
      })
      -- Enable indent lines by default
      vim.g.indent_blankline_enabled = true
    end,
    keys = {
      {
        '<leader>i',
        function() vim.cmd('IndentBlanklineToggle') end,
        desc = "Toggle indent lines"
      }
    }
  },

  {
    -- Commands for closing buffers without closing windows
    'moll/vim-bbye',
    cmd = "Bdelete",
    keys = {
      {
        '<C-_>', function() vim.cmd('Bdelete') end, desc = "Delete buffer",
      }
    }
  },

  {
    -- Space/tab spacing detection
    'Darazaki/indent-o-matic',
    event = { "BufReadPre" },
  },

  {
    -- Pretty fold indicators
    'anuvyklack/pretty-fold.nvim',
    event = "VeryLazy",
  },

  {
    -- Highlight and navigate word under cursor with LSP, TS, or regex
    'RRethy/vim-illuminate',
    event = 'VeryLazy',
    keys = {
      {
        ']r',
        function() require('illuminate').goto_next_reference() end,
        desc = "Go to next reference under cursor"
      },
      {
        '[r',
        function() require('illuminate').goto_prev_reference() end,
        desc = "Go to previous reference under cursor"
      },
    }
  },

  {
    -- Easy surrounding quotes, tags, parens, etc.
    'kylechui/nvim-surround',
    event = "VeryLazy",
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
    -- Plugin dev-oriented tree sitter library
    'windwp/nvim-ts-autotag',
    event = "VeryLazy",
    config = true,
  },

  {
    -- Code commenting plugin
    'numToStr/Comment.nvim',
    event = "VeryLazy",
    config = true,
  },

  {
    'andymass/vim-matchup',
    event = "BufReadPost",
  }
}
