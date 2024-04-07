-- Set <Leader> to space - '\' is too awkward
vim.g.mapleader = " "

-- 5-line up/down jumps
vim.api.nvim_set_keymap('', '<S-k>', '5k', { noremap = true })
vim.api.nvim_set_keymap('', '<S-j>', '5j', { noremap = true })

-- Cuts to black hole buffer
vim.api.nvim_set_keymap('', '<leader>d', '"_d', { noremap = true })
vim.api.nvim_set_keymap('', '<leader>D', '"_D', { noremap = true })
vim.api.nvim_set_keymap('', '<leader>x', '"_x', { noremap = true })

-- Stop j/k working linewise
vim.api.nvim_set_keymap('', 'j', 'gj', { noremap = true })
vim.api.nvim_set_keymap('', 'k', 'gk', { noremap = true })

-- Easy remove highlights over search matches
vim.api.nvim_set_keymap('', '<Bs>', ':noh<CR>', { noremap = true, silent = true })

-- Delete everything between cursor and end of above line
vim.api.nvim_set_keymap('', '<C-j>', ':norm "_d0kgJ"<Enter>', { noremap = true, silent = true })

-- Disable Ex mode
vim.api.nvim_set_keymap('n', 'Q', '<Nop>', {})

-- Shortcut for yanking to system clipboard
vim.api.nvim_set_keymap('n', 'Y', '"+y', {})
vim.api.nvim_set_keymap('v', 'Y', '"+y', {})
