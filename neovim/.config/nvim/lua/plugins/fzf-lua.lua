-- In-nvim FZF

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

local function setup()
  local fzf_lua = require('fzf-lua')
  local actions = require('fzf-lua.actions')

  local function NERDTreeAwareEditAction(selected, opts)
    -- TODO: atm this just moves one buffer to the right, can we change this to most recent buffer?
    if isCursorNvimTreeDir() then vim.cmd('wincmd w') end
    actions.file_edit_or_qf(selected, opts)
  end

  local keymap_opts = { noremap = true, silent = true }
  local grep_defualt_opts = '--color=always --column --line-number --no-heading --smart-case --max-columns=512'

  local grep_winopts = {
    preview = {
      layout = 'flex',
      horizontal = 'right:45%',
      vertical = 'up:40%',
    }
  }

  -- General -------------------------------------------------------------------

  -- Set default config
  fzf_lua.setup({
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
      },
      fzf = {
        ["ctrl-p"] = "toggle-preview",
      },
    }
  })

  -- Fuzzy find filenames
  vim.keymap.set('n', '<C-t>', function() fzf_lua.files({
      winopts = {
        width = 70,
        height = 30,
        preview = {
          hidden = 'hidden',
          layout = 'flex',
          vertical = 'down:60%',
        }
      },
      cwd = NvimTreeAwareCwd(),
      actions = {
        ['default'] = NERDTreeAwareEditAction,
      }
    })
  end, keymap_opts)

  -- Fuzzy find filenames, including ignored files
  vim.keymap.set('n', '<S-t>', function() fzf_lua.files({
      rg_opts = '--color=never --files --hidden --no-ignore-vcs -g "!.git"',
      cwd = NvimTreeAwareCwd(),
    })
  end, keymap_opts)

  -- Fuzzy find text
  vim.keymap.set('n', '\\', function() fzf_lua.grep({
      rg_opts = grep_defualt_opts .. ' --hidden -g "!.git"',
      search = '',
      cwd = NvimTreeAwareCwd(),
      actions = {
        ['default'] = NERDTreeAwareEditAction,
      },
      winopts = grep_winopts,
    })
  end, keymap_opts)

  -- Fuzzy find text, including ignored files
  vim.keymap.set('n', '|', function() fzf_lua.grep({
      rg_opts = grep_defualt_opts .. ' --hidden -g "!.git" --no-ignore-vcs',
      search = '',
      cwd = NvimTreeAwareCwd(),
      actions = {
        ['default'] = NERDTreeAwareEditAction,
      },
      winopts = grep_winopts,
    })
  end, keymap_opts)

  -- TODO: can we just fill the prompt vs this weird invisible grep? -- yep! use 'search' param
  -- Fuzzy find text under cursor
  vim.keymap.set('v', '\\', function() fzf_lua.grep_visual({
      rg_opts = grep_defualt_opts .. ' --hidden -g "!.git"',
      winopts = grep_winopts,
    })
  end, keymap_opts)

  -- Fuzzy highlighted find text, including ignored files
  vim.keymap.set('v', '|', function() fzf_lua.grep_visual({
      rg_opts = grep_defualt_opts .. ' --hidden -g "!.git" --no-ignore-vcs',
      winopts = grep_winopts,
    })
  end, keymap_opts)

  -- Fuzzy find text in current buffer
  vim.keymap.set('n', '<leader>f/', function() fzf_lua.grep_curbuf({
      winopts = grep_winopts,
    })
  end, keymap_opts)

  -- Fuzzy find buffer list
  vim.keymap.set('n', '<S-Tab>', function() fzf_lua.buffers({
      winopts = {
        width = 60,
        height = 22,
        preview = {
          hidden = 'hidden',
          layout = 'flex',
          vertical = 'down:60%',
        }
      },
      cwd = NvimTreeAwareCwd(),
      actions = {
        ['default'] = NERDTreeAwareEditAction,
      }
    })
  end, keymap_opts)


  -- Git ----------------------------------------------------------------------

  vim.keymap.set('n', '<leader>fh', function() fzf_lua.git_bcommits() end, keymap_opts)


  -- LSP ----------------------------------------------------------------------

  -- LSP references of name under cursor
  vim.keymap.set('n', '<leader>fr', function() fzf_lua.lsp_references() end, keymap_opts)


  -- Highlights ----------------------------------------------------------------

  vim.api.nvim_set_hl(0, 'FzfLuaBorder', { link = 'SpecialKey' })
  vim.api.nvim_set_hl(0, 'FzfLuaTitle', { link = 'Conceal' })
end

return {
  name = 'ibhagwan/fzf-lua',
  setup = setup,
  priority = 2,
}
