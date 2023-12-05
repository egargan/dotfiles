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

local grep_defualt_opts = ' --color=always --column --line-number --no-heading --smart-case --max-columns=512'

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
    cmd = { 'FzfLua' },
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
      {
        '<leader>o',
        function()
          require('fzf-lua').jumps({
            winopts = {
              width = 170,
              height = 40,
              preview = {
                layout = 'flex',
                horizontal = 'right:55%',
                vertical = 'up:50%',
              }
            }
          })
        end,
        desc = "Search for text in buffer"
      },
      {
        '<S-Tab>',
        mode = { 'n' },
        function()
          require('fzf-lua').buffers({
            winopts = {
              width = 170,
              height = 40,
              preview = {
                layout = 'flex',
                horizontal = 'right:55%',
                vertical = 'up:50%',
              }
            }
          })
        end,
        desc = "Search for text in buffer"
      },
      {
        '<leader>fs',
        function()
          require('fzf-lua').lsp_live_workspace_symbols({
            winopts = {
              width = 170,
              height = 40,
              preview = {
                layout = 'flex',
                horizontal = 'right:55%',
                vertical = 'up:50%',
              }
            }
          })
        end,
        desc = "Search workspace symbols"
      },
      {
        '<leader><Enter>',
        function()
          require('fzf-lua').commands({
            winopts = {
              width = 75,
              height = 30,
              preview = {
                hidden = 'hidden',
                layout = 'vertical',
                vertical = 'down:60%',
              }
            },
          })
        end,
        desc = "Search commands"
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
      require('ibl').setup({
        indent = {
          char= '│',
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
    -- Commands for opening files, lines in GitHub
    'Almo7aya/openingh.nvim',
    cmd = { 'OpenInGHFile', 'OpenInGHRepo' }
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
    event = { "BufReadPost" },
  },

  {
    -- Show fold contents in popup
    'anuvyklack/fold-preview.nvim',
    event = { "BufReadPost" },
    config = function(_, opts)
      require('fold-preview').setup({
        auto = 2000,
        default_keybindings = false,
        border = 'rounded',
      })
    end,
    keys = {
      {
        'zp',
        function() require('fold-preview').toggle_preview() end,
        desc = "Toggle fold preview"
      },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = {
      "MarkdownPreviewToggle",
      "MarkdownPreview",
      "MarkdownPreviewStop"
    },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  }
}
