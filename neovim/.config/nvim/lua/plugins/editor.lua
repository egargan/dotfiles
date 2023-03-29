local function isCursorNvimTreeDir()
  return vim.bo.filetype == 'NvimTree' and
      require('nvim-tree.api').tree.get_node_under_cursor().fs_stat.type == "directory"
end

local function NvimTreeAwareCwd()
  if isCursorNvimTreeDir() then
    return require('nvim-tree.api').tree.get_node_under_cursor().absolute_path
  else
    return vim.fn.getcwd()
  end
end

local grep_defualt_opts = '--color=always --column --line-number --no-heading --smart-case --max-columns=512'

local grep_winopts = {
  preview = {
    layout = 'flex',
    horizontal = 'right:45%',
    vertical = 'up:40%',
  }
}

return {
  {
    'ibhagwan/fzf-lua',
    opts = {
      winopts = {
        preview = {
          flip_columns = 180,
        },
      },
      keymap = {
        builtin = {
          ['<C-p>'] = 'toggle-preview',
          ['<C-Space>'] = 'toggle-preview-cw',
          ['<C-L>'] = 'toggle-fullscreen',
          ['<C-o>'] = 'toggle-all',
        },
        fzf = {
          ['ctrl-p'] = 'toggle-preview',
          ['ctrl-o'] = 'toggle-all',
        },
      },
      grep = {
        actions = {
          ["ctrl-y"] = function(selected)
            local resultsNoFilenames = {}

            -- For each selected result (may be one or many), trim the filename
            for _, v in pairs(selected) do
              local splitResult = vim.split(v, ":%d+:")
              table.remove(splitResult, 1)
              table.insert(resultsNoFilenames, table.concat(splitResult))
            end

            vim.fn.setreg('"', table.concat(resultsNoFilenames, '\n'))
          end
        },
      },
    },
    config = function(_, opts)
      require('fzf-lua').setup(opts)
      vim.api.nvim_set_hl(0, 'FzfLuaBorder', { link = 'SpecialKey' })
      vim.api.nvim_set_hl(0, 'FzfLuaTitle', { link = 'Conceal' })
    end,
    keys = {
      {
        '<C-t>',
        function()
          require('fzf-lua').files({
            winopts = {
              width = 75,
              height = 30,
              preview = {
                hidden = 'hidden',
                layout = 'flex',
                vertical = 'down:60%',
              }
            },
            cwd = NvimTreeAwareCwd(),
          })
        end,
        desc = "Find files"
      },
      {
        '<S-t>',
        function()
          require('fzf-lua').files({
            rg_opts = '--color=never --files --hidden --no-ignore-vcs -g "!.git"',
            cwd = NvimTreeAwareCwd(),
          })
        end,
        desc = "Find files incl. ignored"
      },
      {
        '\\',
        function()
          require('fzf-lua').grep({
            rg_opts = grep_defualt_opts .. ' --hidden -g "!.git"',
            search = '',
            cwd = NvimTreeAwareCwd(),
            winopts = grep_winopts,
          })
        end,
        desc = "Search for text"
      },
      {
        '|',
        function()
          require('fzf-lua').grep({
            rg_opts = grep_defualt_opts .. ' --hidden -g "!.git" --no-ignore-vcs',
            search = '',
            cwd = NvimTreeAwareCwd(),
            winopts = grep_winopts,
          })
        end,
        desc = "Search for text incl. ignored files"
      },
      -- TODO: can we just fill the prompt vs this weird invisible grep? -- yep! use 'search' param
      {
        '\\',
        mode = { 'v' },
        function()
          require('fzf-lua').grep_visual({
            rg_opts = grep_defualt_opts .. ' --hidden -g "!.git"',
            winopts = grep_winopts,
          })
        end,
        desc = "Search for text under cursor"
      },
      {
        '|',
        mode = { 'v' },
        function()
          require('fzf-lua').grep_visual({
            rg_opts = grep_defualt_opts .. ' --hidden -g "!.git" --no-ignore-vcs',
            winopts = grep_winopts,
          })
        end,
        desc = "Search for text under cursor incl. ignored files"
      },
      {
        '<leader>f/',
        function()
          require('fzf-lua').grep_curbuf({
            winopts = grep_winopts,
          })
        end,
        desc = "Search for text in buffer"
      },
      {
        '<leader>fh',
        function() require('fzf-lua').git_bcommits() end,
        desc = "Search file history"
      },
    },
  },

  {
    -- Show git diff UI in gutter
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
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
      require('indent_blankline').setup({
        show_current_context = true,
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
    -- Commands for opening files, lines in GitHub
    'Almo7aya/openingh.nvim',
    cmd = { 'OpenInGHFile', 'OpenInGHRepo' }
  },

  {
    -- Buffer switcher window
    'toppair/reach.nvim',
    config = function()
      require('reach').setup()

      vim.api.nvim_set_hl(0, 'ReachBorder', { link = '@comment' })
      vim.api.nvim_set_hl(0, 'ReachGrayOut', { link = '@comment' })
      vim.api.nvim_set_hl(0, 'ReachTitle', { link = '@comment' })
      vim.api.nvim_set_hl(0, 'ReachDirectory', { link = '@number' })
      vim.api.nvim_set_hl(0, 'ReachPriority', { link = '@label' })
      vim.api.nvim_set_hl(0, 'ReachHandleBuffer', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'ReachHandleSplit', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'ReachHandleMarkLocal', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'ReachHandleMarkGlobal', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'ReachHandleTabpage', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'ReachHandleDelete', { link = 'DiagnosticError' })
    end,
    keys = {
      {
        '<S-Tab>',
        function()
          require('reach').buffers({
            modified_icon = '+',
            filter = function(bufnr) return not (string.find(vim.api.nvim_buf_get_name(bufnr), 'NvimTree')) end,
            show_current = true,
            previous = {
              depth = 2,
              groups = { '@function', '@keyword' }
            }
          })
        end,
        desc = "Buffer switcher"
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
}