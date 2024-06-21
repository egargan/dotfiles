vim.api.nvim_create_autocmd({ 'BufWritePre', 'BufRead' }, {
  pattern = '.envrc',
  command = 'set filetype=sh',
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  command = ':%s/\\s\\+$//e',
})

-- Delete buffers from buffer list by default
vim.api.nvim_create_autocmd('BufAdd', {
  pattern = '*',
  callback = function(event)
    vim.bo[event.buf].bufhidden = 'delete'
  end
})

-- Keep the buffer around if it's been edited
vim.api.nvim_create_autocmd({ 'BufModifiedSet', 'TextChangedI', 'TextChanged' }, {
  pattern = '*',
  callback = function(event)
    if vim.bo[event.buf].buflisted == true then
      vim.bo['bufhidden'] = 'hide'
    end
  end
})

-- Open help window in a vertical split to the right.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("help_window_right", {}),
  pattern = { "*.txt" },
  callback = function()
    if vim.o.filetype == 'help' then vim.cmd.wincmd("L") end
  end
})

-- Alias 'W' to 'w', no more 'Not an editor command: W'!
vim.api.nvim_create_user_command("W", "write", { nargs = 0 })

-- Clear jump list on startup, avoid jumping to files from previous sessions
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("clear_jumplist", {}),
  command = ':clearjumps',
})

-- Commands for changing indent mode
vim.api.nvim_create_user_command("Spaces2", ":set tabstop=2 shiftwidth=2 expandtab | %retab!", { nargs = 0 })
vim.api.nvim_create_user_command("Spaces4", ":set tabstop=4 shiftwidth=4 expandtab | %retab!", { nargs = 0 })
vim.api.nvim_create_user_command("Tabs2", ":set tabstop=2 shiftwidth=2 noexpandtab | %retab!", { nargs = 0 })
vim.api.nvim_create_user_command("Tabs4", ":set tabstop=4 shiftwidth=4 noexpandtab | %retab!", { nargs = 0 })

-- Add .envrc boilerplate
vim.api.nvim_create_user_command("EnvrcBoilerplate", ":norm ggIsource_up_if_exists .envrc<Enter><Enter><Esc>",
  { nargs = 0 })
