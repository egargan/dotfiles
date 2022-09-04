vim.g.mapleader=" "                   -- Set <Leader> to space - '\' is too awkward

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

-- -----------------------------------------------------------------------------

-- Plugin dev-oriented tree sitter library
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

-- Show git diff UI in gutter
Plug('lewis6991/gitsigns.nvim')

-- Code commenting plugin
Plug('tpope/vim-commentary')

-- Pretty status line
Plug('itchyny/lightline.vim')

-- Easy surrounding quotes, tags, parens, etc.
Plug('tpope/vim-surround')

-- Easy alignment for rows of words, vars, etc.
Plug('junegunn/vim-easy-align')

-- Fuzzy file finding (CLI package + vim wrapper)
-- TODO: potentially installing duplicate fzf if already installed e.g. via
-- dnf, check 'hash fzf' before installing?
Plug('junegunn/fzf', { ['do']= vim.fn['fzf#install'] })
Plug('junegunn/fzf.vim')

-- YAML formatting + highlighting
Plug('mrk21/yaml-vim')

-- Indentation indicators
Plug('lukas-reineke/indent-blankline.nvim')

-- Filesystem explorer
Plug('preservim/nerdtree')

-- Svelte language support
Plug('leafOfTree/vim-svelte-plugin', { ['for'] = {'svelte'} })

-- SCSS syntax support
Plug('cakebaker/scss-syntax.vim', { ['for'] = {'scss'} })

-- Typescript langauge support
Plug('leafgarland/typescript-vim', { ['for'] = 'typescript' })

-- Commands for closing buffers without closing windows
Plug('moll/vim-bbye')

-- In-vim Git handiness
Plug('tpope/vim-fugitive')

-- Nord colorscheme
Plug('arcticicestudio/nord-vim')

-- Convenience function library for plugin devs
Plug('nvim-lua/plenary.nvim')

-- Modal fuzzy finder
Plug('nvim-telescope/telescope.nvim')

-- Better live_grep builtin with highlighting and rg args
Plug('nvim-telescope/telescope-live-grep-args.nvim')

-- Buffer pinning and navigation plugin
Plug('ThePrimeagen/harpoon')


-- LSP Plugins -----------------------------------------------------------------

-- LSP server installer
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')

-- Per-langauge client configs
Plug('neovim/nvim-lspconfig')

-- TODO: Telescope-based file browser
Plug('nvim-telescope/telescope-file-browser.nvim')

-- Completion Plugins  -------------------------------------------------------------

-- Auto-complete Framework
Plug('hrsh7th/nvim-cmp')

-- Collects language server suggestions as completion source
Plug('hrsh7th/cmp-nvim-lsp')

-- Completion source for vim's command line
Plug('hrsh7th/cmp-cmdline')


-- -----------------------------------------------------------------------------

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


-- == Plugin Settings + Mappings ===============================================

-- -- itchyny/lightline --------------------------------------------------------

-- Hide vanilla mode status
vim.opt.showmode = false

vim.g.lightline = {
   ['colorscheme'] = 'nord';
   ['active'] = {
     ['left'] = {
       { 'mode', 'paste' };
       { 'readonly', 'filename' };
       { 'lastbuf' };
     },
     ['right'] = {
       { 'lineinfo' };
       { 'percent' };
       { 'filetype' };
     }
   },
   ['component_function'] = {
     ['filename'] = 'LightlineFilename';
     ['lastbuf'] = 'LightlineLastBuffer';
   },
}

-- Returns Lightline's usual 'filename' string, but without the '|' separating the filename and the
-- modified indicator
function LightlineFilename()
  if vim.fn.expand('%:t') ~= '' then
    return vim.fn.expand('%:t')
  else
    return '[No Name]'
  end

  -- TODO
  -- print(filename .. vim.fn.getbufinfo({listed = 1}))
  -- return filename .. (&modified ? ' +' : '')
end

vim.cmd('let g:LightlineFilename = luaeval("LightlineFilename")')

-- Returns the filename of the 'alternate' buffer, essentially that most-recently opened.
-- TODO: can we fix #'s behavior so it doesn't refer to deleted buffers?
function LightlineLastBuffer()
  return vim.fn.expand('#')
end

vim.cmd('let LightlineLastBuffer = luaeval("LightlineLastBuffer")')

-- Shortcut for opening the most-recently-open buffer
vim.api.nvim_set_keymap('n', '<S-Tab>', ":execute bufnr('#') == -1 ? '' : 'b' . bufnr('#')<Enter>", { noremap = true, silent = true })

-- lewis6991/gitsigns.nvim -----------------------------------------------------

require('gitsigns').setup {
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    -- Navigation
    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true, buffer = bufnr })

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true, buffer = bufnr })

    -- Actions
    -- TODO: do we need all these?
    vim.keymap.set({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', { buffer = bufnr })
    vim.keymap.set({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', { buffer = bufnr })
    vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr })
    vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr })
    vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr })
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr })
    vim.keymap.set('n', '<leader>hb', function() gs.blame_line{full=true} end, { buffer = bufnr })
    vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame, { buffer = bufnr })
    vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr })
    vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, { buffer = bufnr })
    vim.keymap.set('n', '<leader>td', gs.toggle_deleted, { buffer = bufnr })

    -- Text object
    vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { buffer = bufnr })
  end
}

-- junegunn/vim-easy-align -----------------------------------------------------

vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', { noremap = true })
vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', { noremap = true })

-- junegunn/fzf ----------------------------------------------------------------

-- ...

-- lukas-reineke/indent-blankline.nvim -----------------------------------------

-- Disable indent lines by default
vim.g.indent_blankline_enabled = false

-- Add map for toggling lines
vim.api.nvim_set_keymap('n', '<Leader>i', ':IndentBlanklineToggle<Enter>', { noremap = true })

require("indent_blankline").setup {
  -- Highlight the indent level of the cursor's line
  show_current_context = true,
}

-- preservim/nerdtree ----------------------------------------------------------

local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>e', ':NERDTreeToggle<CR>', opts)
vim.keymap.set('n', '<leader>5', ':NERDTreeFind<CR>', opts)


-- leafOfTree/vim-svelte-plugin ------------------------------------------------

-- ...

-- moll/vim-bbye ---------------------------------------------------------------

-- ...

-- arcticicestudio/nord-vim ----------------------------------------------------

vim.cmd('colorscheme nord')

-- nvim-telescope/telescope.nvim --------------------------------------------------------

local telescope_builtins = require('telescope.builtin')
local telescope_themes = require('telescope.themes')

local opts = { noremap = true, silent = true }

vim.keymap.set('n', '\\', telescope_builtins.live_grep, opts)

-- live_grep search with visual selection filled
vim.keymap.set('v', '\\', '"zy:Telescope live_grep default_text=<C-r>z<cr>', opts)

-- TODO: add no-ignore versions of above, don't think the live_grep builtin supports this out the box
-- TODO: add bindings for LSP

vim.keymap.set('n', '<C-t>', function() telescope_builtins.find_files(telescope_themes.get_dropdown()) end, opts)

vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "Comment" })

vim.api.nvim_set_hl(0, "TelescopeResultsLineNr", { link = "Comment" })
vim.api.nvim_set_hl(0, "TelescopeResultsIdentifier", { link = "Comment" })
vim.api.nvim_set_hl(0, "TelescopeResultsNumber", { link = "Comment" })
vim.api.nvim_set_hl(0, "TelescopeMatching", { link = "Annotation" })

require('telescope').setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case"
    }
  }
})

-- TODO
require("telescope").load_extension("file_browser")


-- ThePrimeagen/harpoon --------------------------------------------------------

require("harpoon").setup({
  menu = {
    width = 60,
    height = 6,
  }
})

vim.keymap.set('n', '<C-h>', require('harpoon.mark').add_file, opts)
vim.keymap.set('n', '<S-Tab>', require("harpoon.ui").toggle_quick_menu, opts)

vim.keymap.set('n', '1', function() require("harpoon.ui").nav_file(1) end, opts)
vim.keymap.set('n', '2', function() require("harpoon.ui").nav_file(2) end, opts)
vim.keymap.set('n', '3', function() require("harpoon.ui").nav_file(3) end, opts)
vim.keymap.set('n', '4', function() require("harpoon.ui").nav_file(4) end, opts)
vim.keymap.set('n', '5', function() require("harpoon.ui").nav_file(5) end, opts)
vim.keymap.set('n', '6', function() require("harpoon.ui").nav_file(6) end, opts)

vim.api.nvim_set_hl(0, "HarpoonBorder", { link = "Comment" })

-- TODO: display harpoon marks in status line?
-- require('harpoon.mark').get_marked_file_name(idx)

-- TODO: hide numbers in tabline, avoid confusion between it + harpoon

-- LSP Settings ================================================================

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- on_attach means these settings will only be applied once the server attaches to the buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- TODO: work through these
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<Leader>f', vim.lsp.buf.formatting, bufopts)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- Disable diagnostic signs, they look ugly next to git signs
    signs = false,
  }
)

-- Show black circle instead of default square for virtual text diagnostic messages
vim.diagnostic.config({ virtual_text = { prefix = ' ●' } })

-- Language settings -----------------------------------------------------

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require('lspconfig')['tsserver'].setup{
  on_attach = on_attach,
  filetypes = { "typescript", "javascript" },
  capabilities = capabilities,
}

local lua_config = {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- TODO: find a way of forcing the workspace to '.config/nvim', the current hack is to put an
-- empty 'stylua.toml' file next to this, without it sumneok_lua assumes ~ is the working
-- directory, which the language server will refuse to load
-- if vim.fn.getreg('%') == '.config/nvim/init.lua' then
-- ...
-- end

require('lspconfig')['sumneko_lua'].setup(lua_config)

-- williamboman/mason.nvim -----------------------------------------------------

require('mason').setup()

-- hrsh7th/nvim-cmp + friends -----------------------------------------------------

-- Set up nvim-cmp
local cmp = require('cmp')

cmp.setup({
  window = {
    completion = cmp.config.window.bordered({
      winhighlight = "Normal:Normal,FloatBorder:Comment,CursorLine:PmenuSel,Search:None",
    }),
    documentation = cmp.config.window.bordered({
      winhighlight = "Normal:Normal,FloatBorder:Comment,CursorLine:PmenuSel,Search:None",
    })
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    -- Scroll complete docs menu
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    -- Select next or previous suggestion
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    -- Manually trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),
    -- Close completion menu
    ['<C-c>'] = cmp.mapping.abort(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  })
})

-- Use cmdline source for ':'
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'cmdline' }
  })
})


-- General Settings ============================================================

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
vim.opt.undodir = '~/.nvim/undo'           -- Set loc for undo history

-- create undo dir if !exists
vim.fn.system('silent ! [ -d ' .. vim.opt.undodir:get()[1] ..
  '] || mkdir ' .. vim.opt.undodir:get()[1])

vim.opt.directory = '~/.nvim/swap//'       -- Keep swaps in home dir (trailing '//' creates full-path-name .swps)

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
vim.api.nvim_set_keymap('', '<leader>c', '"_c', { noremap = true })
vim.api.nvim_set_keymap('', '<leader>C', '"_C', { noremap = true })
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


-- Autocommands  ===============================================================

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  command = ':%s/\\s\\+$//e',
})

-- Host-specific config ========================================================

local private_config_path = '~/.config/nvim/init.lua.private'

if vim.fn.filereadable(vim.fn.expand(private_config_path)) ~= 0 then
  require(private_config_path)
end
