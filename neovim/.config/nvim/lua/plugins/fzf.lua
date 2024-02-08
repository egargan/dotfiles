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
    event = "VeryLazy", -- Load before commands/keys so we can 'register_ui_select'
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

      -- Use FzfLua for vim.ui.select prompts
      require('fzf-lua').register_ui_select({
        winopts = {
          width = 75,
          height = 20,
          preview = {
            hidden = 'hidden',
            layout = 'flex',
            vertical = 'down:60%',
          }
        },
      })
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
}
