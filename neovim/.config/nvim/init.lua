-- Sometimes Neovim doesn't think .nvim should be its runtime path?
vim.opt.rtp:append(vim.env.HOME .. '/.nvim/')

-- Import base config
require("settings")
require("keymaps")
require("autocommands")

-- Install Lazy plugin manager if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Setup plugins, including LSP and completion config
-- TODO: load subset when running with viq
require("lazy").setup({
  spec = {
    { import = "plugins.coding" },
    { import = "plugins.colorscheme" },
    { import = "plugins.completion" },
    { import = "plugins.core" },
    { import = "plugins.editor" },
    { import = "plugins.lsp" },
    { import = "plugins.treesitter" },
    { import = "plugins.ui" },
  },
  ui = {
    border = "rounded",
  },
  change_detection = {
    enabled = false,
  },
})

-- Load host-specific config, if it exists
local private_config_path = '$HOME/.config/nvim/lua/private-init.lua'

if vim.fn.filereadable(vim.fn.expand(private_config_path)) ~= 0 then
  require('private-init')
end
