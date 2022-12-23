-- Git blame dialogs

function setup()
  -- Add map for showing GitMessenger blame popup
  vim.api.nvim_set_keymap('n', '<Leader>b', ':GitMessenger<CR>', { noremap = true, silent = true })

  vim.api.nvim_set_hl(0, 'gitmessengerHeader', { link = 'Conditional' })
  vim.api.nvim_set_hl(0, 'gitmessengerPopupNormal', { link = 'Normal' })
  vim.api.nvim_set_hl(0, 'gitmessengerHash', { link = 'String' })
  vim.api.nvim_set_hl(0, 'gitmessengerHistory', { link = 'DiagnosticInfo' })

  vim.g.git_messenger_floating_win_opts = { border = 'single' }
  vim.g.git_messenger_popup_content_margins = 'h:true'
end

return {
  name = 'rhysd/git-messenger.vim',
  setup = setup,
  priority = 1,
}
