-- Plugin dev-oriented tree sitter library

function setup()
  require('nvim-treesitter.configs').setup({
    highlight = {
      enable = true
    },
    indent = {
      enable = true
    },
    ensure_installed = { "svelte", "typescript", "lua", "html", "scss", "python", "yaml", "json", "query" },
  })
end

return {
  name = 'nvim-treesitter/nvim-treesitter',
  options = { ['do'] = ':TSUpdate' },
  setup = setup,
  priority = 2,
}
