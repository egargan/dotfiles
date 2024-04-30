-- Sometimes Neovim doesn't think .nvim should be its runtime path?
vim.opt.rtp:append(vim.env.HOME .. '/.nvim/')

-- Import base config
require("settings")
require("keymaps")
require("autocommands")

require('plugins.init')({
  "plugins.completion",
  "plugins.lib",
  "plugins.session",
  "plugins.editing",
  "plugins.formatting",
  "plugins.fzf",
  "plugins.lsp",
  "plugins.nord",
  "plugins.tools",
  "plugins.treesitter",
  "plugins.ui",
})
