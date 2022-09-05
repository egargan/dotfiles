-- Filesystem explorer

function setup()
  local opts = { noremap = true, silent = true }

  vim.keymap.set('n', '<leader>e', ':NERDTreeToggle<CR>', opts)
  vim.keymap.set('n', '<leader>5', ':NERDTreeFind<CR>', opts)
end

return {
  name = 'preservim/nerdtree',
  setup = setup,
}

