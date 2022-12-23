-- Indentation indicators

function setup()
  -- Disable indent lines by default
  vim.g.indent_blankline_enabled = false

  -- Add map for toggling lines
  vim.api.nvim_set_keymap('n', '<Leader>i', ':IndentBlanklineToggle<Enter>', { noremap = true })

  require("indent_blankline").setup {
    -- Highlight the indent level of the cursor's line
    show_current_context = true,
  }
end

return {
  name = 'lukas-reineke/indent-blankline.nvim',
  setup = setup,
}
