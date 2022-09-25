-- Plugin dev-oriented tree sitter library

function setup()
  require('nvim-treesitter.configs').setup({
    ensure_installed = { "svelte", "typescript", "lua" },
  })
end

return {
  name = 'nvim-treesitter/nvim-treesitter',
  options = { ['do'] = ':TSUpdate' },
  setup = setup,
  priority = 2,
}
