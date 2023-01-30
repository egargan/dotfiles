-- Plugin dev-oriented tree sitter library

local hl = function(group, opts)
  opts.default = true
  vim.api.nvim_set_hl(0, group, opts)
end

function setup()
  require('nvim-treesitter.configs').setup({
    highlight = {
      enable = true,
    },
    indent = {
      enable = true
    },
    autotag = {
      enable = true,
    },
    ensure_installed = { "svelte", "typescript", "lua", "html", "scss", "python", "yaml", "json", "query", "javascript" },
  })
end

return {
  name = 'nvim-treesitter/nvim-treesitter',
  options = { ['do'] = ':TSUpdate' },
  setup = setup,
  priority = 2,
}
