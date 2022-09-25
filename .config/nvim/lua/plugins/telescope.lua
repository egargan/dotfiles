-- Modal fuzzy finder for everything under the sun

function setup()
  local builtins = require('telescope.builtin')

  local opts = { noremap = true, silent = true }

  local vimgrep_args = {
    'rg',
    '--no-heading',
    '--with-filename',
    '--line-number',
    '--column',
    '--smart-case'
  }

  local vimgrep_args_no_ignore = {}
  for _, v in ipairs(vimgrep_args) do table.insert(vimgrep_args_no_ignore, v) end
  table.insert(vimgrep_args_no_ignore, '--no-ignore')

  require('telescope').setup({
    defaults = {
      vimgrep_arguments = vimgrep_args,
      layout_config = { width = 0.75, height = 0.75 },
      mappings = {
        i = {
          ["<C-Up>"] = require('telescope.actions').cycle_history_next,
          ["<C-Down>"] = require('telescope.actions').cycle_history_prev,
          ["<C-p>"] = require('telescope.actions.layout').toggle_preview,
          ["<C-l>"] = require('telescope.actions.layout').cycle_layout_next,
        },
      }
    },
  })

  -- TODO: move this to the file_browser plugin setup?
  require("telescope").load_extension("file_browser")

  -- Fuzzy find filenames
  vim.keymap.set('n', '<C-t>', function() builtins.find_files({
    -- TODO: make this a custom strategy,
    layout_strategy = 'vertical',
    layout_config = { width = 80, height = 0.5 },
    previewer = false,
  }) end, opts)
  -- Fuzzy find filenames, including ignored files
  vim.keymap.set('n', '<S-T>', function() builtins.find_files({
    layout_config = { width = 80, height = 0.5 },
    layout_strategy = 'vertical',
    vimgrep_arguments = vimgrep_args_no_ignore,
    previewer = false,
  }) end, opts)

  -- Fuzzy find text
  vim.keymap.set('n', '<leader>fg', builtins.live_grep, opts)
  -- Fuzzy find text, including ignored file
  vim.keymap.set('n', '<leader>fG', function() builtins.live_grep({
    vimgrep_arguments = vimgrep_args_no_ignore,
  }) end, opts)
  -- Fuzzy find text, pre-filled with selection
  -- TODO: make --no-ignore version
  vim.keymap.set('v', '<leader>fg', '"zy:Telescope live_grep default_text=<C-r>z<cr>', opts)

  -- Fuzzy search buffers
  -- TODO: add multi select resolve for harpoon
  vim.keymap.set('n', '<leader>fb', function() builtins.buffers({
    layout_strategy = 'vertical',
    layout_config = { width = 80, height = 20 },
    previewer = false,
  }) end, opts)

  -- TODO: add bindings for LSP

  vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "Comment" })
  vim.api.nvim_set_hl(0, "TelescopeResultsLineNr", { link = "Comment" })
  vim.api.nvim_set_hl(0, "TelescopeResultsIdentifier", { link = "Comment" })
  vim.api.nvim_set_hl(0, "TelescopeResultsNumber", { link = "Comment" })
  vim.api.nvim_set_hl(0, "TelescopeMatching", { link = "Annotation" })

end

return {
  name = 'nvim-telescope/telescope.nvim',
  setup = setup,
  priority = 1,
}
