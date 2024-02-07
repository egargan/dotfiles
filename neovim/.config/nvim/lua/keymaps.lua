-- Set <Leader> to space - '\' is too awkward
vim.g.mapleader = " "

-- Larger split resizing
vim.api.nvim_set_keymap('n', '<C-w>/', '<C-w>10>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>/', '<C-w>10>', { noremap = true })

-- Speedy tab management
vim.api.nvim_set_keymap('n', ']t', ':tabnext<Enter>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[t', ':tabprev<Enter>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']T', ':tabnew<Enter>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[T', ':tabclose<Enter>', { noremap = true, silent = true })

-- Quickfix list navigation
vim.api.nvim_set_keymap('n', ']q', ':cnext<Enter>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[q', ':cprev<Enter>', { noremap = true, silent = true })

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

-- Don't jump to next match when *ing
vim.api.nvim_set_keymap('n', '*', '*``', { noremap = true })

-- Easy remove highlights over search matches
vim.api.nvim_set_keymap('', '<Bs>', ':noh<CR>', { noremap = true, silent = true })

-- s///g macro for word under cursor - applies to whole file in
-- normal mode, or to selection only in visual mode
vim.api.nvim_set_keymap('n', '<leader>r', ':%s/\\<<C-r><C-w>\\>//g<left><left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>r', ':s/\\<<C-r><C-w>\\>//g<left><left>', { noremap = true, silent = true })

-- Delete everything between cursor and end of above line
vim.api.nvim_set_keymap('', '<C-j>', ':norm "_d0kgJ"<Enter>', { noremap = true, silent = true })

-- Override default print filename map to also set the system clipboard
vim.api.nvim_set_keymap('n', '<C-g>', ':let @+ = expand("%")<Enter> <Bar> :echo expand("%")<Enter>',
  { noremap = true, silent = true })

-- Keep buffer in bufferlist if it leaves a window
vim.api.nvim_set_keymap('n', '<C-h>', ':set bufhidden=hide<CR>', { noremap = true, silent = true })

-- ...
-- vim.api.nvim_set_keymap('n', '<silent>', '[Q :call RemoveLineFromQuickFix()<cr>', { noremap = true })

-- Disable Ex mode
vim.api.nvim_set_keymap('n', 'Q', '<Nop>', {})

-- Mapping for closing Vim in a hurry
vim.api.nvim_set_keymap('n', 'QQ', ':qa!<Enter>', { noremap = true, silent = true })

-- Easy normal mode in terminal
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

-- Shortcut for yanking to system clipboard
vim.api.nvim_set_keymap('n', 'Y', '"+y', {})
vim.api.nvim_set_keymap('v', 'Y', '"+y', {})
