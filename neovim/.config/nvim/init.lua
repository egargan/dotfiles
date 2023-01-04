vim.g.mapleader=" "                   -- Set <Leader> to space - '\' is too awkward
vim.opt.rtp:append(vim.env.HOME .. '/.nvim/')     -- Sometimes Neovim doesn't think .nvim should be its runtime path?

-- == Plugins ==================================================================

local vimplug_install_path = '~/.nvim/autoload/plug.vim'

-- Install vimplug if not already installed
if vim.fn.glob(vimplug_install_path) == '' then
  vim.fn.system('curl --create-dirs -fLo ' .. vimplug_install_path ..
    '\\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
end

local Plug = vim.fn['plug#']
local vimplug_plugin_dir = '~/.nvim/plugged'

vim.call('plug#begin', vimplug_plugin_dir)

-- General Plugins
local general_plugin_confs = {}

-- TODO: can we do this more elegantly?
for _, value in pairs(vim.fn.systemlist('ls $HOME/.config/nvim/lua/plugins | sed -e \'s/\\.lua$//\'')) do
  local conf = require('plugins.' .. value)
  if conf.priority == nil then conf.priority = 10 end
  if not conf.disabled then
    table.insert(general_plugin_confs, conf)
  end
end

for _, conf in pairs(general_plugin_confs) do
  if conf.options ~= nil then
    vim.fn['plug#'](conf.name, conf.options or {})
  else
    vim.fn['plug#'](conf.name)
  end
end

-- LSP Plugins
local lsp_conf = require('lsp')
for _, plugin in pairs(lsp_conf.plugins) do
  vim.fn['plug#'](plugin)
end

-- Completion plugins
local cmp_conf = require('completion')
for _, plugin in pairs(cmp_conf.plugins) do
  vim.fn['plug#'](plugin)
end

local missing_plugin_names = {}

-- Create list of plugged plugins that aren't installed
for plugins_i = 1, #vim.g.plugs_order do
  local plugin_name = vim.g.plugs_order[plugins_i]
  if vim.fn.glob(vimplug_plugin_dir .. '/' .. plugin_name) == '' then
    table.insert(missing_plugin_names, plugin_name)
  end
end

if next(missing_plugin_names) ~= nil then
  vim.api.nvim_create_autocmd('VimEnter', {
    pattern = '*',
    command = 'PlugInstall --sync ' .. table.concat(missing_plugin_names, ' ')
  })
end

-- Initialise vimplug
vim.call('plug#end')

-- Sort plugins by priority
table.sort(general_plugin_confs, function(a, b) return a.priority < b.priority end)

-- Call post-plug setup for plugins
for _, conf in pairs(general_plugin_confs) do
  if conf.setup ~= nil then
    conf.setup()
  end
end

lsp_conf.setup()
cmp_conf.setup()


-- General Settings ============================================================

vim.opt.updatetime = 500                  -- Time between swap file writes and for CursorHold delay

vim.opt.syntax = 'on'                      -- Syntax highlighting
vim.opt.number = true                      -- Line numbers

vim.opt.expandtab = true                      -- Always enter spaces on <Tab>
vim.opt.softtabstop = 2                  -- How many spaces are entered on <Tab>
vim.opt.shiftwidth = 2                   -- Tab width used by 'smarttab', and '>>'/'<<
vim.opt.shiftround = true                     -- Round '>>/'<<' indents to nearest tabstop

vim.opt.scrolloff = 4                    -- Always keep cursor >= 4 lines away from top and bottom of screen
vim.opt.linebreak = true                      -- Don't wrap lines in the middle of words
vim.opt.colorcolumn = '100'                -- Show line length boundary at line 100
vim.opt.tw = 100                         -- Set word wrap width to 100
vim.opt.laststatus = 2                   -- Always show status bar
vim.opt.cursorline = true                     -- Highlight cursor's line

vim.opt.wildmode = { 'longest', 'list' }          -- (on tab, complete to longest common path, or show options if not possible) TODO: do we need these, next to FZF?
vim.opt.wildignore = { '.git', '*.swp', '*/tmp/*' }

vim.opt.undofile = true                       -- Lave undo history to file
vim.opt.undoreload = 1000               -- Limit history to 1k lines
vim.opt.undodir =  vim.fn.expand('~') .. '/.nvim/swap//'  -- Set loc for undo history

-- create undo dir if !exists
vim.fn.system('silent ! [ -d ' .. vim.opt.undodir:get()[1] ..
  '] || mkdir ' .. vim.opt.undodir:get()[1])

vim.opt.directory = vim.fn.expand('~') .. '/.nvim/swap//'   -- Keep swaps in home dir (trailing '//' creates full-path-name .swps)

-- create swap dir if !exists
vim.fn.system('silent ! [ -d ' .. vim.opt.directory:get()[1] ..
  '] || mkdir ' .. vim.opt.directory:get()[1])

vim.opt.ignorecase = true                     -- Ignore case in searches by default
vim.opt.smartcase = true                      -- Enable case sensitivity if capital entered

vim.opt.relativenumber = true                 -- Line numbers are relative to cursor's line

vim.opt.termguicolors = true                  -- Use colorscheme's 256-bit colours


-- General Mappings ============================================================

-- Larger split resizing
vim.api.nvim_set_keymap('n', '<C-w>/', '<C-w>10>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>/', '<C-w>10>', { noremap = true })

-- Speedy tab navigation
vim.api.nvim_set_keymap('n', ']t', ':tabnext<Enter>', { noremap = true })
vim.api.nvim_set_keymap('n', '[t', ':tabprev<Enter>', { noremap = true })

-- Faster new tab
vim.api.nvim_set_keymap('n', ']T', ':tabnew<Enter>', { noremap = true })

-- Quickfix list navigation
vim.api.nvim_set_keymap('n', ']q', ':cnext<Enter>', { noremap = true })
vim.api.nvim_set_keymap('n', '[q', ':cprev<Enter>', { noremap = true })

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
vim.api.nvim_set_keymap('', '<Bs>', ':noh<CR>', { noremap = true })

-- s///g macro for word under cursor - applies to whole file in
-- normal mode, or to selection only in visual mode
vim.api.nvim_set_keymap('n', '<leader>r', ':%s/\\<<C-r><C-w>\\>//g<left><left>', { noremap = true })
vim.api.nvim_set_keymap('v', '<leader>r', ':s/\\<<C-r><C-w>\\>//g<left><left>', { noremap = true })

-- Delete everything between cursor and end of above line
vim.api.nvim_set_keymap('', '<C-j>', ':norm "_d0kgJ"<Enter>', { noremap = true })

-- Override default print filename map to also set the system clipboard
vim.api.nvim_set_keymap('n', '<C-g>', ':let @+ = expand("%")<Enter> <Bar> :echo expand("%")<Enter>', { noremap = true })

-- ...
-- vim.api.nvim_set_keymap('n', '<silent>', '[Q :call RemoveLineFromQuickFix()<cr>', { noremap = true })

-- Disable Ex mode
vim.api.nvim_set_keymap('n', 'Q', '<Nop>', {})

-- Mapping for closing Vim in a hurry
vim.api.nvim_set_keymap('n', 'QQ', ':qa!<Enter>', { noremap = true })

-- Easy normal mode in terminal
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

-- Convert snake case to camelcase (temporary)
vim.api.nvim_set_keymap('v', 'sc', [[:s/\%V_\(\l\)/\u\1/g<Enter>]], { noremap = true })


-- General Highlights ==========================================================

-- Override 'float' highlights to just use base colours
vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'Comment' })
vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })


-- Autocommands  ===============================================================

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  command = ':%s/\\s\\+$//e',
})

-- Host-specific config ========================================================

local private_config_path = '$HOME/.config/nvim/lua/private-init.lua'

if vim.fn.filereadable(vim.fn.expand(private_config_path)) ~= 0 then
  require('private-init')
end
