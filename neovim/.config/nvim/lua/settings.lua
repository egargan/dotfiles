vim.opt.updatetime = 500                 -- Time between swap file writes and for CursorHold delay

vim.opt.syntax = 'on'                    -- Syntax highlighting
vim.opt.number = true                    -- Line numbers

vim.opt.expandtab = true                 -- Always enter spaces on <Tab>
vim.opt.softtabstop = 2                  -- How many spaces are entered on <Tab>
vim.opt.tabstop = 2                      -- If using tabs, set tab width
vim.opt.shiftwidth = 2                   -- Tab width used by 'smarttab', and '>>'/'<<
vim.opt.shiftround = true                -- Round '>>/'<<' indents to nearest tabstop

vim.opt.scrolloff = 4                    -- Always keep cursor >= 4 lines away from top and bottom of screen
vim.opt.linebreak = true                 -- Don't wrap lines in the middle of words
vim.opt.tw = 100                         -- Set word wrap width to 100
vim.opt.laststatus = 3                   -- Always show full-width status bar
vim.opt.cursorline = true                -- Highlight cursor's line

vim.opt.wildmode = { 'longest', 'list' } -- (on tab, complete to longest common path, or show options if not possible) TODO: do we need these, next to FZF?
vim.opt.wildignore = { '.git', '*.swp', '*/tmp/*' }

vim.opt.undofile = true                                 -- Lave undo history to file
vim.opt.undoreload = 1000                               -- Limit history to 1k lines
vim.opt.undodir = vim.fn.expand('~') .. '/.nvim/swap//' -- Set loc for undo history

-- create undo dir if !exists
vim.fn.system('silent ! [ -d ' .. vim.opt.undodir:get()[1] ..
  '] || mkdir ' .. vim.opt.undodir:get()[1])

vim.opt.directory = vim.fn.expand('~') ..
    '/.nvim/swap//' -- Keep swaps in home dir (trailing '//' creates full-path-name .swps)

-- create swap dir if !exists
vim.fn.system('silent ! [ -d ' .. vim.opt.directory:get()[1] ..
  '] || mkdir ' .. vim.opt.directory:get()[1])

vim.opt.ignorecase = true     -- Ignore case in searches by default
vim.opt.smartcase = true      -- Enable case sensitivity if capital entered

vim.opt.relativenumber = true -- Line numbers are relative to cursor's line

vim.opt.termguicolors = true  -- Use colorscheme's 256-bit colours

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 7
vim.opt.foldcolumn = '0'
vim.opt.foldlevelstart = 99
