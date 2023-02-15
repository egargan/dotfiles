-- Easy alignment for rows of words, vars, etc.

function setup()
  vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', { noremap = true })
  vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', { noremap = true })
end

return {
    name = 'junegunn/vim-easy-align',
    setup = setup,
}
