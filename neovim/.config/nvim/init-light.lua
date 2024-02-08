-- Sometimes Neovim doesn't think .nvim should be its runtime path?
vim.opt.rtp:append(vim.env.HOME .. '/.nvim/')

require("settings")
require("keymaps")
require("autocommands")

require('plugins.init')({
  "plugins.core",
  "plugins.editing",
  "plugins.formatting",
  "plugins.fzf",
  "plugins.nord",
  "plugins.tools",
  "plugins.treesitter",
  "plugins.ui",
})
