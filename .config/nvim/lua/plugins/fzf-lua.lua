-- In-nvim FZF

local function isBufferNERDTree()
  return vim.bo.filetype == 'nerdtree' and
    vim.api.nvim_eval([[has_key(g:NERDTreeDirNode.GetSelected(), 'path')]])
end

local function NERDTreeAwareCwd()
  if isBufferNERDTree() then
    return vim.api.nvim_eval([[g:NERDTreeDirNode.GetSelected().path.str()]])
  else
    return vim.fn.getcwd()
  end
end

local function setup()
  local fzf_lua = require('fzf-lua')
  local actions = require('fzf-lua.actions')

  local function NERDTreeAwareEditAction(selected, opts)
    -- TODO: atm this just moves one buffer to the right, can we change this to most recent buffer?
    if isBufferNERDTree() then vim.cmd('wincmd w') end
    actions.file_edit_or_qf(selected, opts)
  end

  local opts = { noremap = true, silent = true }

  -- General -------------------------------------------------------------------

  -- Fuzzy find filenames
  vim.keymap.set('n', '<C-t>', function() fzf_lua.files({
    winopts = {
      width = 60,
      height = 30,
      preview = {
        layout = 'vertical',
      }
    },
    cwd = NERDTreeAwareCwd(),
    actions = {
      ['default'] = NERDTreeAwareEditAction,
    }
  }) end, opts)

  -- Fuzzy find filenames, including ignored files
  vim.keymap.set('n', '<S-t>', function() fzf_lua.files({
    rg_opts = '--color=never --files --hidden --no-ignore-vcs -g "!.git"',
    cwd = NERDTreeAwareCwd(),
  }) end, opts)

  -- Fuzzy find text
  vim.keymap.set('n', '\\', function() fzf_lua.grep({
    search = '',
    cwd = NERDTreeAwareCwd(),
    actions = {
      ['default'] = NERDTreeAwareEditAction,
    }
  }) end, opts)

  -- Fuzzy find text, including ignored files
  vim.keymap.set('n', '|', function() fzf_lua.grep({
    rg_opts = '--color=never --files --hidden --no-ignore-vcs -g "!.git"',
    search = '',
    cwd = NERDTreeAwareCwd(),
    actions = {
      ['default'] = NERDTreeAwareEditAction,
    }
  }) end, opts)

  -- TODO: can we just fill the prompt vs this weird invisible grep? -- yep! use 'search' param
  -- Fuzzy find text under cursor
  vim.keymap.set('v', '\\', function() fzf_lua.grep_visual() end, opts)

  -- Fuzzy find text, including ignored files
  vim.keymap.set('v', '|', function() fzf_lua.grep_visual({
    rg_opts = '--color=never --files --hidden -g "!.git" --no-ignore-vcs'
  }) end, opts)

  -- Fuzzy find text in current buffer
  vim.keymap.set('v', '<leader>f/', function() fzf_lua.grep_curbuf() end, opts)

  -- Fuzzy find buffer list
  vim.keymap.set('n', '<leader>fb', function() fzf_lua.buffers({
    actions = {
      ["ctrl-d"] = { actions.buf_del, actions.resume },
      ["ctrl-h"] = function(selected)
        for _, selection in ipairs(selected) do
          print(selection)
          local buffer = tonumber(selection:match("%[(%d+)"))
          -- TODO: can we do this with the buffer index directly?
          require('harpoon.mark').add_file(vim.api.nvim_buf_get_name(buffer))
        end

        require('harpoon.ui').toggle_quick_menu()
      end
    }
  }) end, opts)


  -- Git ----------------------------------------------------------------------

  vim.keymap.set('n', '<leader>fh', function() fzf_lua.git_bcommits() end, opts)


  -- LSP ----------------------------------------------------------------------

  -- LSP diagnostics
  vim.keymap.set('n', '<leader>fd', function() fzf_lua.diagnostics_document() end, opts)

  -- LSP references of name under cursor
  vim.keymap.set('n', '<leader>fr', function() fzf_lua.lsp_references() end, opts)


  -- Highlights ----------------------------------------------------------------

  vim.api.nvim_set_hl(0, 'FzfLuaBorder', { link = 'SpecialKey' })
  vim.api.nvim_set_hl(0, 'FzfLuaTitle', { link = 'Conceal' })
end

return {
  name = 'ibhagwan/fzf-lua',
  setup = setup,
  priority = 2,
}
